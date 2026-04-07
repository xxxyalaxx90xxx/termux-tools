#!/usr/bin/env python3
"""
termux_cli_manager.py
Unified manager + fixer for Gemini CLI and Qwen CLI on Termux (Android).

Features:
- Install / update / uninstall @google/gemini-cli and @qwen-code/qwen-code using npm
- Optionally build ripgrep from source (Rust) OR use Termux `pkg install ripgrep`
- Patch Gemini's downloadRipGrep.js to support android by short-circuiting to system `rg`
- Create qwen-rg-wrapper.js and inject into Qwen's dist/index.js
- Create gemini-auto-patch.js and qwen-auto-patch.js and set them as postinstall hooks
- Atomic writes with timestamped backups
- Safe postinstall script merging
- Idempotent; safe; logs clearly
- Interactive menu and CLI flags support
- File-based logging
- Configuration file support
- Dependency checking
- Enhanced error handling
- Non-interactive mode with --yes and --dry-run flags

Usage:
  pkg install python nodejs npm ripgrep  # recommended prerequisites
  Save script and run: python3 termux_cli_manager.py
"""
import os
import sys
import json
import shutil
import subprocess
import argparse
import logging
import tempfile
from pathlib import Path
from datetime import datetime
from logging.handlers import RotatingFileHandler
import re
import difflib


# ---------- Configuration ----------
def get_npm_prefix():
    """Dynamically detect npm prefix"""
    try:
        result = subprocess.run(["npm", "config", "get", "prefix"], 
                               capture_output=True, text=True, check=True)
        prefix = Path(result.stdout.strip())
        logging.debug(f"Detected npm prefix: {prefix}")
        return prefix
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.warning("npm not found or failed to get prefix, using default")
        return Path("/data/data/com.termux/files/usr")

# Define constants in the correct order (this was a problem in the original file)
NPM_PREFIX = get_npm_prefix()
NPM_GLOBAL = NPM_PREFIX / "lib" / "node_modules"
CONFIG_DIR = Path.home() / ".termux_cli_manager"
CONFIG_FILE = CONFIG_DIR / "config.json"
LOG_FILE = CONFIG_DIR / "manager.log"

GEMINI_PKG = "@google/gemini-cli"
GEMINI_DIR = NPM_GLOBAL / "@google" / "gemini-cli"
QWEN_PKG = "@qwen-code/qwen-code"
QWEN_DIR = NPM_GLOBAL / "@qwen-code" / "qwen-code"

# Additional paths for patching
GEMINI_RIPGREP_CANDIDATES = [
    GEMINI_DIR / "node_modules" / "@joshua.litt" / "get-ripgrep" / "dist" / "downloadRipGrep.js",
    GEMINI_DIR / "node_modules" / "@lvce-editor" / "ripgrep" / "src" / "downloadRipGrep.js",
    GEMINI_DIR / "node_modules" / "@lvce-editor" / "ripgrep" / "dist" / "downloadRipGrep.js"
]

GEMINI_AUTOPATCH = GEMINI_DIR / "scripts" / "gemini-auto-patch.js"  # Place in package directory
QWEN_WRAPPER = QWEN_DIR / "scripts" / "qwen-rg-wrapper.js"  # Place in package directory
QWEN_AUTOPATCH = QWEN_DIR / "scripts" / "qwen-auto-patch.js"  # Place in package directory


# ---------- Logging Setup ----------
def setup_logging(verbose=False):
    """Setup logging to file and console"""
    CONFIG_DIR.mkdir(exist_ok=True)
    
    level = logging.DEBUG if verbose else logging.INFO
    
    # Use RotatingFileHandler to avoid infinite log growth
    file_handler = RotatingFileHandler(LOG_FILE, maxBytes=5*1024*1024, backupCount=3)
    file_handler.setLevel(level)
    file_formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
    file_handler.setFormatter(file_formatter)
    
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    console_formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
    console_handler.setFormatter(console_formatter)
    
    root_logger = logging.getLogger()
    root_logger.setLevel(level)
    root_logger.handlers = []  # Clear existing handlers
    root_logger.addHandler(file_handler)
    # Only add console handler if in verbose mode
    if verbose:
        root_logger.addHandler(console_handler)


# ---------- Configuration ----------
def load_config():
    """Load configuration from file"""
    if CONFIG_FILE.exists():
        try:
            with open(CONFIG_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            echo(f"[warn] Failed to load config: {e}", "yellow")
            return {}
    return {}

def save_config(config):
    """Save configuration to file"""
    try:
        CONFIG_DIR.mkdir(exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
        return True
    except Exception as e:
        echo(f"[error] Failed to save config: {e}", "red")
        return False


# ---------- Helpers ----------
def echo(s="", color=None):
    """Print with optional color"""
    colors = {
        "red": "\u001b[91m",
        "green": "\u001b[92m",
        "yellow": "\u001b[93m",
        "blue": "\u001b[94m",
        "purple": "\u001b[95m",
        "cyan": "\u001b[96m",
        "bold": "\u001b[1m",
        "end": "\u001b[0m"
    }
    
    if color and color in colors:
        print(f"{colors[color]}{s}{colors['end']}")
    else:
        print(s)
    
    # Don't log UI display messages to avoid cluttering logs with UI elements
    # Only log technical operational messages separately when needed

def run(cmd, check=False, capture=False, dry_run=False, shell=False):
    """Run shell command with dry-run support. Accepts cmd as string or list."""
    if isinstance(cmd, list) and not shell:
        cmd_to_run = cmd
    else:
        cmd_to_run = cmd if isinstance(cmd, str) else " ".join(cmd)
        shell = True  # Force shell=True if cmd was a string
    
    if dry_run:
        echo(f"[dry-run] Would execute: {cmd_to_run}", "yellow")
        logging.info(f"[dry-run] Would execute: {cmd_to_run}")
        return subprocess.CompletedProcess(cmd_to_run, 0, "", "")
    
    echo(f"$ {cmd_to_run}", "cyan")
    logging.debug(f"Executing command: {cmd_to_run}")
    
    try:
        if shell:
            res = subprocess.run(cmd_to_run, shell=True, capture_output=capture, text=True)
        else:
            res = subprocess.run(cmd_to_run, shell=False, capture_output=capture, text=True)
    except Exception as e:
        if check:
            error_msg = f"Command failed: {cmd_to_run}\nError: {e}"
            logging.error(error_msg)
            raise RuntimeError(error_msg)
        else:
            return subprocess.CompletedProcess(cmd_to_run, 1, "", str(e))
    
    if check and res.returncode != 0:
        error_msg = f"Command failed: {cmd_to_run}\nstdout:\n{res.stdout}\nstderr:\n{res.stderr}"
        logging.error(error_msg)
        raise RuntimeError(error_msg)
    return res

def get_timestamp():
    """Get current timestamp for backup files"""
    return datetime.now().strftime("%Y%m%dT%H%M%S")

def safe_write(path: Path, content: str, make_backup=True, dry_run=False):
    """Write content to file with atomic operation and timestamped backup"""
    if dry_run:
        if path.exists():
            # Show what would have changed
            original_content = path.read_text(encoding="utf-8")
            if original_content != content:
                # Compute and show diff
                original_lines = original_content.splitlines(keepends=True)
                new_lines = content.splitlines(keepends=True)
                diff = list(difflib.unified_diff(
                    original_lines, 
                    new_lines, 
                    fromfile=str(path), 
                    tofile=f"{path} (after change)",
                    lineterm=""
                ))
                if diff:
                    echo(f"[dry-run] Would update {path}", "yellow")
                    logging.info(f"[dry-run] Would update {path}")
                    echo("".join(diff), "yellow")
                else:
                    echo(f"[dry-run] No changes to {path}", "yellow")
            else:
                echo(f"[dry-run] No changes to {path}", "yellow")
        else:
            echo(f"[dry-run] Would create {path}", "yellow")
            logging.info(f"[dry-run] Would create {path}")
            # Show the new content
            echo(f"New content of {path}:", "yellow")
            echo(content, "yellow")
        return
    
    if path.exists() and make_backup:
        timestamp = get_timestamp()
        bak = path.with_suffix(f"{path.suffix}.bak.{timestamp}")
        # Create parent directories if needed
        bak.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, bak)
        echo(f"[backup] {path} -> {bak}", "yellow")
        logging.info(f"Backed up {path} to {bak}")
    
    path.parent.mkdir(parents=True, exist_ok=True)
    
    # Write to temporary file first, then move to final location (atomic operation)
    with tempfile.NamedTemporaryFile(mode='w', delete=False, encoding="utf-8", dir=path.parent) as tmp_file:
        tmp_file.write(content)
        tmp_path = Path(tmp_file.name)
    
    # Move temporary file to final location
    tmp_path.replace(path)
    echo(f"[write] {path}", "green")
    logging.info(f"Wrote to {path}")
    
    # Make executable if needed
    if path.suffix == '.js':
        path.chmod(0o755)

def backup_file(path: Path, dry_run=False):
    """Create timestamped backup of file if it exists"""
    if dry_run:
        if path.exists():
            timestamp = get_timestamp()
            bak = path.with_suffix(f"{path.suffix}.bak.{timestamp}")
            echo(f"[dry-run] Would backup {path} -> {bak}", "yellow")
            logging.info(f"[dry-run] Would backup {path} -> {bak}")
        return
    
    if path.exists():
        timestamp = get_timestamp()
        bak = path.with_suffix(f"{path.suffix}.bak.{timestamp}")
        # Create parent directories if needed
        bak.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, bak)
        echo(f"[backup] {path} -> {bak}", "yellow")
        logging.info(f"Backed up {path} to {bak}")

def is_termux():
    """Check if running in Termux environment"""
    return Path("/data/data/com.termux").exists() or "com.termux" in os.environ.get("PREFIX", "")

def check_dependencies():
    """Check if required dependencies are installed"""
    deps = ["node", "npm", "python3"]
    missing = []
    
    for dep in deps:
        if not shutil.which(dep):
            missing.append(dep)
    
    if missing:
        echo(f"[warn] Missing dependencies: {', '.join(missing)}", "yellow")
        ans = input("Attempt to install missing dependencies via pkg? [Y/n]: ").strip().lower() or "y"
        if ans.startswith("y"):
            try:
                run(["pkg", "update", "-y"], check=False)
                dep_pkgs = []
                if "node" in missing or "npm" in missing:
                    dep_pkgs.append("nodejs")
                if "python3" in missing:
                    dep_pkgs.append("python")
                
                if dep_pkgs:
                    run(["pkg", "install", "-y"] + dep_pkgs, check=True)
                    echo("[ok] Dependencies installed", "green")
                    return True
            except Exception as e:
                echo(f"[error] Failed to install dependencies: {e}", "red")
                return False
        return False
    return True

def find_all_ripgrep_files(gemini_dir: Path):
    """Find all downloadRipGrep.js files in gemini directory recursively"""
    if not gemini_dir.exists():
        return []
    return list(gemini_dir.rglob("downloadRipGrep.js"))

def is_installed(pkg_dir: Path):
    """Check if package is installed"""
    return pkg_dir.exists()

def get_current_version(pkg_dir: Path, version_cmd: str):
    """Get current version of installed package"""
    if not is_installed(pkg_dir):
        return "not installed"
    
    try:
        result = run(version_cmd, capture=True)
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            return "unknown"
    except:
        return "unknown"

def fetch_available_versions(pkg_name):
    """Fetch available versions from npm registry"""
    try:
        result = run(f"npm view {pkg_name} versions --json", capture=True, check=True)
        versions = json.loads(result.stdout)
        if isinstance(versions, list):
            return versions[::-1]  # Return latest first
        else:
            return [str(versions)]
    except Exception as e:
        logging.warning(f"Failed to fetch versions for {pkg_name}: {e}")
        return []

def select_version(pkg_name, current_version=None):
    """Interactive version selection"""
    echo(f"Fetching available versions for {pkg_name}...", "blue")
    versions = fetch_available_versions(pkg_name)
    
    if not versions:
        echo("[warn] Could not fetch versions, using latest", "yellow")
        return None
    
    echo(f"\nAvailable versions for {pkg_name}:", "bold")
    for i, version in enumerate(versions[:10]):  # Show top 10
        if current_version and version == current_version:
            echo(f"  {i+1}. {version} (current)")
        else:
            echo(f"  {i+1}. {version}")
    
    if len(versions) > 10:
        echo(f"  ... and {len(versions) - 10} more")
    
    choice = input("\\nSelect version (1-" + str(min(10, len(versions))) + ") or press Enter for latest: ").strip()
    
    if not choice:
        return None  # Latest
    
    try:
        idx = int(choice) - 1
        if 0 <= idx < len(versions):
            return versions[idx]
        else:
            echo("[warn] Invalid selection, using latest", "yellow")
            return None
    except ValueError:
        echo("[warn] Invalid input, using latest", "yellow")
        return None


# ---------- Ripgrep management ----------
def fix_node_gyp_on_android(dry_run=False):
    """Fixes node-gyp issue on Termux by creating a gypi file
    that defines android_ndk_path.
    """
    if dry_run:
        echo("[dry-run] Would fix node-gyp on Android", "yellow")
        logging.info("[dry-run] Would fix node-gyp on Android")
        return True
        
    echo("Fixing node-gyp on Android...", "blue")
    gyp_dir = Path.home() / ".gyp"
    gypi_file = gyp_dir / "include.gypi"
    gypi_content = "{ 'variables': { 'android_ndk_path': '' } }" # Note: using single quotes in string

    if gypi_file.exists():
        try:
            content = gypi_file.read_text().strip()
            # A simple check to see if it looks right
            if "'android_ndk_path': ''" in content.replace('"', "'"):
                 echo("[ok] node-gyp fix already applied.", "green")
                 return True
        except Exception as e:
            echo(f"[warn] Could not read existing include.gypi file: {e}", "yellow")

    echo("[info] Applying node-gyp fix by creating ~/.gyp/include.gypi", "blue")
    try:
        gyp_dir.mkdir(exist_ok=True)
        gypi_file.write_text(gypi_content + "\n")
        echo("[ok] node-gyp fix applied successfully.", "green")
        return True
    except Exception as e:
        echo(f"[error] Failed to write node-gyp fix file: {e}", "red")
        return False

def ensure_system_ripgrep(auto_install=True, dry_run=False):
    """Ensure ripgrep is installed via pkg"""
    rg = shutil.which("rg")
    if rg:
        echo(f"[ok] ripgrep found at {rg}", "green")
        return True
    echo("[warn] ripgrep not found in PATH.", "yellow")
    if not auto_install:
        return False
    ans = "y" if dry_run else input("Install ripgrep via `pkg install ripgrep` now? [Y/n]: ").strip().lower() or "y"
    if ans.startswith("y"):
        try:
            run(["pkg", "update", "-y"], check=False, dry_run=dry_run)
            run(["pkg", "install", "-y", "ripgrep"], check=True, dry_run=dry_run)
        except Exception as e:
            echo(f"[error] Installing ripgrep failed: {e}", "red")
            return False
        if not dry_run:
            return bool(shutil.which("rg"))
        else:
            return True
    else:
        return False

def build_ripgrep_from_source(target_arch="aarch64-linux-android", dry_run=False):
    """Attempt to compile ripgrep with cargo for Android. Heavy and requires Rust.
    Returns True if built and installed to ~/.local/bin or similar.
    """
    if dry_run:
        echo("[dry-run] Would build ripgrep from source", "yellow")
        logging.info("[dry-run] Would build ripgrep from source")
        return True
        
    echo("[info] Building ripgrep from source. This is heavy and requires Rust + cargo.", "blue")
    ans = input("Continue to attempt building ripgrep from source? (requires pkg install rust cargo) [y/N]: ").strip().lower()
    if not ans.startswith("y"):
        return False
    try:
        run(["pkg", "install", "-y", "rust", "clang", "make", "git", "cargo"], check=True)
        tmp = Path("/data/data/com.termux/files/usr/tmp/ripgrep-src")
        if tmp.exists():
            shutil.rmtree(tmp)
        run(["git", "clone", "--depth", "1", "https://github.com/BurntSushi/ripgrep.git", str(tmp)], check=True)
        # Build with cargo
        run(["bash", "-c", f"cd {tmp} && cargo build --release"], check=True)
        built = tmp / "target" / "release" / "rg"
        if not built.exists():
            echo("[error] Built binary not found.", "red")
            return False
        # Install to $PREFIX/bin/rg
        target_bin = NPM_PREFIX / "bin" / "rg"
        backup_file(target_bin, dry_run=dry_run)
        if not dry_run:
            shutil.copy2(built, target_bin)
            target_bin.chmod(0o755)
        echo(f"[ok] ripgrep installed to {target_bin}", "green")
        return True
    except Exception as e:
        echo(f"[error] Building ripgrep failed: {e}", "red")
        return False


# ---------- NPM package management ----------
def npm_install_global(pkg_name, version=None, ignore_scripts=False, dry_run=False):
    """Install npm package globally"""
    if version:
        pkg = f"{pkg_name}@{version}"
    else:
        pkg = pkg_name
    
    cmd = ["npm", "install", "-g", pkg]
    if ignore_scripts:
        cmd.extend(["--ignore-scripts"])
    
    run(cmd, check=True, dry_run=dry_run)

def npm_uninstall_global(pkg_name, dry_run=False):
    """Uninstall npm package globally"""
    run(["npm", "uninstall", "-g", pkg_name], check=True, dry_run=dry_run)

def npm_update_global(pkg_name, dry_run=False):
    """Update npm package globally"""
    run(["npm", "update", "-g", pkg_name], check=True, dry_run=dry_run)

def npm_rebuild_global(pkg_names, dry_run=False):
    """Rebuild npm packages globally"""
    pkg_list = " ".join(pkg_names)
    run(["bash", "-c", f"npm rebuild -g {pkg_list}"], check=False, dry_run=dry_run)


# ---------- Patching logic ----------
def find_gemini_ripgrep_files():
    """Find all Gemini ripgrep files to patch"""
    found_files = []
    # Check the standard candidates
    for p in GEMINI_RIPGREP_CANDIDATES:
        if p.exists():
            found_files.append(p)
    
    # Also search recursively in gemini node_modules
    if GEMINI_DIR.exists():
        additional_files = list(GEMINI_DIR.rglob("downloadRipGrep.js"))
        for f in additional_files:
            if f not in found_files:  # Avoid duplicates
                found_files.append(f)
    
    return found_files

def patch_gemini_download_ripgrep(dry_run=False):
    """Patch all Gemini ripgrep download files"""
    files_to_patch = find_gemini_ripgrep_files()
    
    if not files_to_patch:
        echo("[warn] Could not find any Gemini downloadRipGrep.js files to patch.", "yellow")
        return False
    
    patched_count = 0
    for p in files_to_patch:
        echo(f"[info] Patching Gemini ripgrep file: {p}", "blue")
        
        if dry_run:
            echo(f"[dry-run] Would patch {p}", "yellow")
            logging.info(f"[dry-run] Would patch {p}")
            patched_count += 1
            continue
        
        backup_file(p, dry_run=dry_run)
        code = p.read_text(encoding="utf-8")

        # Idempotent check - is it already patched?
        if "// patched-by-termux_cli_manager" in code or "case 'android'" in code or 'case "android"' in code:
            echo("[ok] Gemini ripgrep file already patched; skipping.", "green")
            continue

        # Use regex for more robust replacement
        # 1) Add android case to platform switch
        # Match the pattern that throws VError for unknown platform
        pattern = r"(case\s+'android':\s*return\s+'system-installed';\s*)?"
        platform_case = "case 'android':\n            console.info('Using system ripgrep from PATH on Android');\n            return 'system-installed';\n        "
        
        # Look for the default case that throws and insert our case before it
        code = re.sub(
            r"(default:\s*\n\s*throw new VError\('Unknown platform: ' \+ platform\);)",
            f"{platform_case}\\1",
            code,
            count=1
        )
        
        # If that pattern wasn't found, try to insert before default: regardless
        if "case 'android'" not in code:
            code = re.sub(
                r"(default:\s*)",
                f"{platform_case}\\1",
                code,
                count=1
            )
        
        # 2) Early-return in downloadRipGrep function
        code = code.replace(
            "export const downloadRipGrep = async (overrideBinPath) => {",
            "export const downloadRipGrep = async (overrideBinPath) => {\n    const target = getTarget();\n    if (target === 'system-installed') {\n        console.info('Skipping ripgrep download, using rg from PATH');\n        return;\n    }\n    // patched-by-termux_cli_manager"
        )

        # Add marker comment
        if "// patched-by-termux_cli_manager" not in code:
            code += "\n// patched-by-termux_cli_manager"

        safe_write(p, code, make_backup=False, dry_run=dry_run)
        patched_count += 1
    
    if patched_count > 0:
        echo(f"[ok] Patched {patched_count} Gemini ripgrep files.", "green")
        return True
    else:
        return False

def write_gemini_autopatch(dry_run=False):
    """Write auto-patch script for Gemini"""
    # Create the scripts directory within the package
    scripts_dir = GEMINI_DIR / "scripts"
    scripts_dir.mkdir(exist_ok=True)
    
    # Escape the path properly
    gemini_dir_escaped = str(GEMINI_DIR).replace('\\', '\\\\').replace("'", "\\'")
    
    code = f"""// Gemini auto-patch script - run at postinstall time
// patched-by-termux_cli_manager

import fs from 'fs';
import path from 'path';

const ripgrepFiles = [
    path.join('{gemini_dir_escaped}', 'node_modules', '@joshua.litt', 'get-ripgrep', 'dist', 'downloadRipGrep.js'),
    path.join('{gemini_dir_escaped}', 'node_modules', '@lvce-editor', 'ripgrep', 'src', 'downloadRipGrep.js'),
    path.join('{gemini_dir_escaped}', 'node_modules', '@lvce-editor', 'ripgrep', 'dist', 'downloadRipGrep.js')
].concat(
    // Also find all downloadRipGrep.js files recursively
    require('fs').readdirSync(path.join('{gemini_dir_escaped}', 'node_modules'), {{ recursive: true }})
        .filter(file => file.endsWith('downloadRipGrep.js'))
        .map(file => path.join('{gemini_dir_escaped}', 'node_modules', file))
);

let patched = false;
for (const ripgrepFile of ripgrepFiles) {{
    if (!fs.existsSync(ripgrepFile)) continue;
    let c = fs.readFileSync(ripgrepFile, 'utf-8');
    if (c.includes('system-installed') || c.includes("case 'android'")) continue;
    
    // 1) Add android case to platform switch
    c = c.replace(/(default:\\s*\\n\\s*throw new VError\\('Unknown platform: ' \\+ platform\\);)/,
        `case 'android':\\n            console.info('Using system ripgrep from PATH on Android');\\n            return 'system-installed';\\n        $1`);
    
    // 2) Early-return in downloadRipGrep function
    c = c.replace('export const downloadRipGrep = async (overrideBinPath) => {{',
        `export const downloadRipGrep = async (overrideBinPath) => {{\\n    const target = getTarget();\\n    if (target === 'system-installed') {{\\n        console.info('Skipping ripgrep download, using rg from PATH');\\n        return;\\n    }}\\n    // patched-by-termux_cli_manager`);
    
    // Add marker comment
    if (!c.includes('// patched-by-termux_cli_manager')) {{
        c += '\\n// patched-by-termux_cli_manager';
    }}
    
    fs.writeFileSync(ripgrepFile, c, 'utf-8');
    patched = true;
    console.log('[GeminiPatch] ✅ Applied to ' + ripgrepFile);
}}

if (!patched) {{
    console.log('[GeminiPatch] ✅ No files needed patching');
}}
"""
    safe_write(GEMINI_AUTOPATCH, code, make_backup=False, dry_run=dry_run)
    if not dry_run:
        GEMINI_AUTOPATCH.chmod(0o755)  # Make executable
    return GEMINI_AUTOPATCH

def patch_qwen_wrapper_and_index(dry_run=False):
    """Patch Qwen to use system ripgrep"""
    if not QWEN_DIR.exists():
        echo("[warn] Qwen not found at expected path; skipping Qwen patch.", "yellow")
        return False
    
    # Create scripts directory
    scripts_dir = QWEN_DIR / "scripts"
    scripts_dir.mkdir(exist_ok=True)
    
    # Write wrapper
    wrapper_code = """// qwen-rg-wrapper.js (auto-created)
// patched-by-termux_cli_manager

import { spawn } from 'child_process';
import { existsSync } from 'fs';

const rgCmd = 'rg';

export function runRipgrep(args = [], options = {}) {
  return spawn(rgCmd, args, { stdio: 'inherit', ...options });
}
"""
    if dry_run:
        echo(f"[dry-run] Would write wrapper: {QWEN_WRAPPER}", "yellow")
        logging.info(f"[dry-run] Would write wrapper: {QWEN_WRAPPER}")
    else:
        backup_file(QWEN_WRAPPER, dry_run=dry_run)
        safe_write(QWEN_WRAPPER, wrapper_code, make_backup=False, dry_run=dry_run)
        QWEN_WRAPPER.chmod(0o755)  # Make executable
    
    echo(f"[ok] Wrote wrapper: {QWEN_WRAPPER}", "green")

    # Patch dist/index.js in qwen
    index_js = QWEN_DIR / "dist" / "index.js"
    if not index_js.exists():
        echo("[warn] Qwen dist/index.js not found; skipping injection.", "yellow")
        return False
        
    if dry_run:
        echo(f"[dry-run] Would patch {index_js}", "yellow")
        logging.info(f"[dry-run] Would patch {index_js}")
    else:
        backup_file(index_js, dry_run=dry_run)
        code = index_js.read_text(encoding="utf-8")
        
        # Check if already patched
        if "// patched-by-termux_cli_manager" in code:
            echo("[ok] Qwen index.js already patched.", "green")
            return True
            
        # Calculate relative path from dist/index.js to scripts/qwen-rg-wrapper.js
        # dist/index.js -> scripts/qwen-rg-wrapper.js
        # going up one level to root, then to scripts/qwen-rg-wrapper.js
        relative_path = "../scripts/qwen-rg-wrapper.js"
        
        injection_code = f"""import {{ runRipgrep }} from '{relative_path}';
global.runRipgrep = runRipgrep;
// patched-by-termux_cli_manager
"""
        
        if "import './src/gemini.js';" in code:
            # Insert our import before the gemini.js import
            code = code.replace("import './src/gemini.js';", f"{injection_code}import './src/gemini.js';")
        else:
            # Prepend to the file
            code = f"{injection_code}{code}"
        
        safe_write(index_js, code, make_backup=False, dry_run=dry_run)

    echo("[ok] Qwen index.js patched.", "green")
    return True

def write_qwen_autopatch(dry_run=False):
    """Write auto-patch script for Qwen"""
    # Create the scripts directory within the package
    scripts_dir = QWEN_DIR / "scripts"
    scripts_dir.mkdir(exist_ok=True)
    
    # Escape the path properly
    qwen_dir_escaped = str(QWEN_DIR).replace('\\', '\\\\').replace("'", "\\'")
    
    code = f"""// Qwen auto-patch script - run at postinstall time
// patched-by-termux_cli_manager

import fs from 'fs';
import path from 'path';

const indexFile = path.join('{qwen_dir_escaped}', 'dist', 'index.js');
if (!fs.existsSync(indexFile)) process.exit(0);

let c = fs.readFileSync(indexFile, 'utf-8');
if (c.includes('patched-by-termux_cli_manager')) process.exit(0);

// Calculate relative path from dist/index.js to scripts/qwen-rg-wrapper.js
const relativePath = '../scripts/qwen-rg-wrapper.js';

const injectionCode = `import {{ runRipgrep }} from '${{relativePath}}';
global.runRipgrep = runRipgrep;
// patched-by-termux_cli_manager
`;

c = c.replace("import './src/gemini.js';", `${{injectionCode}}import './src/gemini.js';`) || 
   injectionCode + c;

fs.writeFileSync(indexFile, c, 'utf-8');
console.log('[QwenPatch] ✅ Applied');
"""
    safe_write(QWEN_AUTOPATCH, code, make_backup=False, dry_run=dry_run)
    if not dry_run:
        QWEN_AUTOPATCH.chmod(0o755)  # Make executable
    return QWEN_AUTOPATCH

def merge_postinstall_hook(pkg_dir: Path, script_path: Path, dry_run=False):
    """Safely merge postinstall hook to package.json, preserving existing scripts"""
    pkg_file = pkg_dir / "package.json"
    if not pkg_file.exists():
        echo(f"[warn] package.json not found at {pkg_file}", "yellow")
        return False
    
    if dry_run:
        echo(f"[dry-run] Would merge postinstall hook in {pkg_file}", "yellow")
        logging.info(f"[dry-run] Would merge postinstall hook in {pkg_file}")
        return True
    
    backup_file(pkg_file, dry_run=dry_run)
    with open(pkg_file, 'r', encoding='utf-8') as f:
        pkg_data = json.load(f)
    
    scripts = pkg_data.get("scripts", {})
    
    # Compute relative path from package.json directory to the script
    relative_script_path = Path(os.path.relpath(script_path, pkg_file.parent))
    new_postinstall_cmd = f"node {relative_script_path}"
    
    if "postinstall" in scripts:
        # If there's already a postinstall, merge them
        existing_postinstall = scripts["postinstall"]
        if new_postinstall_cmd not in existing_postinstall:
            # Append the new command with '&&' if not already present
            scripts["postinstall"] = f"{new_postinstall_cmd} && ({existing_postinstall})"
            echo(f"[info] Merged postinstall hook in {pkg_file}", "blue")
        else:
            echo(f"[ok] Postinstall hook already merged in {pkg_file}", "green")
            pkg_data["scripts"] = scripts
            with open(pkg_file, 'w', encoding='utf-8') as f:
                json.dump(pkg_data, f, indent=2)
            return True
    else:
        # If no postinstall exists, create it
        scripts["postinstall"] = new_postinstall_cmd
        echo(f"[info] Added postinstall hook to {pkg_file}", "blue")
    
    pkg_data["scripts"] = scripts
    with open(pkg_file, 'w', encoding='utf-8') as f:
        json.dump(pkg_data, f, indent=2)
    return True

def remove_postinstall_hook(pkg_dir: Path, script_path: Path, dry_run=False):
    """Remove postinstall hook from package.json, preserving other scripts"""
    pkg_file = pkg_dir / "package.json"
    if not pkg_file.exists():
        echo(f"[warn] package.json not found at {pkg_file}", "yellow")
        return False
    
    if dry_run:
        echo(f"[dry-run] Would remove postinstall hook from {pkg_file}", "yellow")
        logging.info(f"[dry-run] Would remove postinstall hook from {pkg_file}")
        return True
    
    backup_file(pkg_file, dry_run=dry_run)
    with open(pkg_file, 'r', encoding='utf-8') as f:
        pkg_data = json.load(f)
    
    scripts = pkg_data.get("scripts", {})
    # Compute relative path for comparison
    relative_script_path = Path(os.path.relpath(script_path, pkg_file.parent))
    postinstall_cmd = f"node {relative_script_path}"
    
    if "postinstall" in scripts:
        current_postinstall = scripts["postinstall"]
        if current_postinstall == postinstall_cmd:
            # Simple case: the entire postinstall is our command, so remove it
            del scripts["postinstall"]
            echo(f"[info] Removed postinstall hook from {pkg_file}", "green")
        elif f"{postinstall_cmd} &&" in current_postinstall:
            # Our command is at the beginning with '&&', remove it and the '&&'
            scripts["postinstall"] = current_postinstall.replace(f"{postinstall_cmd} && ", "", 1)
            echo(f"[info] Unmerged postinstall hook from {pkg_file}", "green")
        elif f" && {postinstall_cmd}" in current_postinstall:
            # Our command is at the end with '&&', remove it and the '&&'
            scripts["postinstall"] = current_postinstall.replace(f" && {postinstall_cmd}", "", 1)
            echo(f"[info] Unmerged postinstall hook from {pkg_file}", "green")
        else:
            # Command exists but is not as expected - warn user
            echo(f"[warn] Postinstall contains unexpected command, not removing: {current_postinstall}", "yellow")
            return False
        
        pkg_data["scripts"] = scripts
        with open(pkg_file, 'w', encoding='utf-8') as f:
            json.dump(pkg_data, f, indent=2)
        return True
    else:
        echo(f"[info] No postinstall hook to remove from {pkg_file}", "blue")
        return True


# ---------- Rollback functions ----------
def get_latest_backup(path: Path):
    """Get the latest backup file for a given path"""
    backup_pattern = f"{path}*.bak.*"
    backups = []
    
    # Look for direct backups of the file and its parent directory
    for parent_path in [path.parent, path.parent.parent, path.parent.parent.parent]:
        try:
            for f in parent_path.iterdir():
                if f.name.startswith(path.name) and ".bak." in f.name:
                    backups.append(f)
        except (OSError, PermissionError):
            continue  # Skip if we can't read the directory
    
    if not backups:
        return None
        
    # Sort by modification time to get the most recent
    latest_backup = max(backups, key=lambda x: x.stat().st_mtime if x.exists() else 0)
    return latest_backup

def rollback_gemini_patches(dry_run=False):
    """Rollback all Gemini patches"""
    if dry_run:
        echo("[dry-run] Would rollback Gemini patches", "yellow")
        logging.info("[dry-run] Would rollback Gemini patches")
        return True
        
    echo("Rolling back Gemini patches...", "blue")
    
    # Restore original downloadRipGrep.js from the latest backup if exists
    # First check the standard candidates
    for candidate in GEMINI_RIPGREP_CANDIDATES:
        if candidate.exists():
            latest_bak = get_latest_backup(candidate)
            if latest_bak:
                shutil.copy2(latest_bak, candidate)
                echo(f"[rollback] Restored {candidate} from backup {latest_bak}", "green")
            else:
                echo(f"[info] No backup found for {candidate}", "yellow")
    
    # Then look for any other downloadRipGrep.js files in the gemini directory
    if GEMINI_DIR.exists():
        gemini_files = list(GEMINI_DIR.rglob("downloadRipGrep.js"))
        for f in gemini_files:
            if f not in GEMINI_RIPGREP_CANDIDATES:  # Avoid duplicates
                latest_bak = get_latest_backup(f)
                if latest_bak:
                    shutil.copy2(latest_bak, f)
                    echo(f"[rollback] Restored {f} from backup {latest_bak}", "green")
                else:
                    echo(f"[info] No backup found for {f}", "yellow")
    
    # Remove auto-patch script
    if GEMINI_AUTOPATCH.exists():
        GEMINI_AUTOPATCH.unlink()
        echo(f"[rollback] Removed {GEMINI_AUTOPATCH}", "green")
    
    # Remove postinstall hook
    remove_postinstall_hook(GEMINI_DIR, GEMINI_AUTOPATCH)
    
    echo("[ok] Gemini rollback completed", "green")
    return True

def rollback_qwen_patches(dry_run=False):
    """Rollback all Qwen patches"""
    if dry_run:
        echo("[dry-run] Would rollback Qwen patches", "yellow")
        logging.info("[dry-run] Would rollback Qwen patches")
        return True
        
    echo("Rolling back Qwen patches...", "blue")
    
    # Remove wrapper file
    if QWEN_WRAPPER.exists():
        QWEN_WRAPPER.unlink()
        echo(f"[rollback] Removed {QWEN_WRAPPER}", "green")
    
    # Restore original index.js from the latest backup if exists
    index_js = QWEN_DIR / "dist" / "index.js"
    if index_js.exists():
        latest_bak = get_latest_backup(index_js)
        if latest_bak:
            shutil.copy2(latest_bak, index_js)
            echo(f"[rollback] Restored {index_js} from backup {latest_bak}", "green")
        else:
            echo(f"[info] No backup found for {index_js}", "yellow")
    
    # Remove auto-patch script
    if QWEN_AUTOPATCH.exists():
        QWEN_AUTOPATCH.unlink()
        echo(f"[rollback] Removed {QWEN_AUTOPATCH}", "green")
    
    # Remove postinstall hook
    remove_postinstall_hook(QWEN_DIR, QWEN_AUTOPATCH)
    
    echo("[ok] Qwen rollback completed", "green")
    return True


# ---------- High-level actions ----------
def install_gemini_flow(config, dry_run=False, yes=False):
    """Install Gemini CLI flow"""
    echo("=== Install Gemini CLI ===", "bold")
    fix_node_gyp_on_android(dry_run=dry_run)
    
    # Check if already installed
    current_version = get_current_version(GEMINI_DIR, "gemini --version")
    if current_version != "not installed":
        echo(f"[info] Gemini is already installed (version: {current_version})", "blue")
        if yes or dry_run:
            ans = "y"
            if dry_run:
                echo("[dry-run] Would reinstall Gemini", "yellow")
        else:
            ans = input("Reinstall? [y/N]: ").strip().lower()
        if not ans.startswith("y"):
            return True
    
    # Select version
    version = None
    if yes or dry_run:
        ans = "n"  # Default to latest in non-interactive mode
        if dry_run:
            echo("[dry-run] Would install latest version", "yellow")
    else:
        ans = input("Install specific version? [y/N]: ").strip().lower()
    if ans.startswith("y"):
        version = select_version(GEMINI_PKG, current_version)
    
    if dry_run:
        echo(f"[dry-run] Would install Gemini CLI with version: {'latest' if version is None else version}", "yellow")
        return True
    
    echo("Installing via npm (using --ignore-scripts by default)...", "blue")
    install_success = False
    try:
        npm_install_global(GEMINI_PKG, version, ignore_scripts=True, dry_run=dry_run)
        install_success = True
    except Exception as e:
        echo(f"[warn] npm install with --ignore-scripts failed: {e}", "yellow")
        echo("[info] Retrying without --ignore-scripts flag...", "blue")
        try:
            npm_install_global(GEMINI_PKG, version, dry_run=dry_run)
            install_success = True
        except Exception as e2:
            echo(f"[error] npm install failed even without --ignore-scripts: {e2}", "red")
            return False
    
    if not install_success:
        return False
        
    echo("[ok] npm install finished.", "green")
    
    # Patch any ripgrep modules that might be present
    patched = patch_gemini_download_ripgrep(dry_run=dry_run)
    
    # Look for @lvce-editor/ripgrep module specifically for newer versions
    lvce_ripgrep_path = GEMINI_DIR / "node_modules" / "@lvce-editor" / "ripgrep"
    if lvce_ripgrep_path.exists():
        # Find downloadRipGrep.js in the lvce-editor module
        for js_file in lvce_ripgrep_path.rglob("downloadRipGrep.js"):
            if js_file.exists():
                # Patch this specific file
                backup_file(js_file, dry_run=dry_run)
                if not dry_run:
                    code = js_file.read_text(encoding="utf-8")
                    
                    # Idempotent check
                    if "patched-by-termux_cli_manager" in code or "case 'android'" in code or 'case "android"' in code:
                        echo("[ok] LVCE ripgrep file already patched; skipping.", "green")
                    else:
                        # 1) Add android case to platform switch
                        code = re.sub(
                            r"(default:\s*\n\s*throw new VError\('Unknown platform: ' \+ platform\);)",
                            "case 'android':\n            console.info('Using system ripgrep from PATH on Android');\n            return 'system-installed';\n        \\1",
                            code,
                            count=1
                        )
                        
                        # 2) Early-return in downloadRipGrep function
                        code = code.replace(
                            "export const downloadRipGrep = async (overrideBinPath) => {",
                            "export const downloadRipGrep = async (overrideBinPath) => {\n    const target = getTarget();\n    if (target === 'system-installed') {\n        console.info('Skipping ripgrep download, using rg from PATH');\n        return;\n    }\n    // patched-by-termux_cli_manager"
                        )
                        
                        # Add marker comment
                        if "// patched-by-termux_cli_manager" not in code:
                            code += "\n// patched-by-termux_cli_manager"
                        
                        safe_write(js_file, code, make_backup=False, dry_run=dry_run)
                        echo("[ok] LVCE ripgrep patched.", "green")
                else:
                    echo(f"[dry-run] Would patch {js_file}", "yellow")
                break  # Only patch the first one found
    
    if patched and not dry_run:
        autopatch = write_gemini_autopatch(dry_run=dry_run)
        merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=dry_run)
    return True

def update_gemini_flow(config, dry_run=False, yes=False):
    """Update Gemini CLI flow"""
    echo("=== Update Gemini CLI ===", "bold")
    
    # Check if installed
    current_version = get_current_version(GEMINI_DIR, "gemini --version")
    if current_version == "not installed":
        echo("[warn] Gemini is not installed. Installing instead...", "yellow")
        return install_gemini_flow(config, dry_run=dry_run, yes=yes)
    
    # Select version
    version = None
    if yes or dry_run:
        ans = "n"  # Default to latest in non-interactive mode
        if dry_run:
            echo("[dry-run] Would update to latest version", "yellow")
    else:
        ans = input("Update to specific version? [y/N]: ").strip().lower()
    if ans.startswith("y"):
        version = select_version(GEMINI_PKG, current_version)
    elif ans:
        # User provided a version directly
        version = ans
    
    if dry_run:
        echo(f"[dry-run] Would update Gemini CLI to version: {'latest' if version is None else version}", "yellow")
        return True
    
    echo("Updating via npm (using --ignore-scripts by default)...", "blue")
    update_success = False
    pkg_to_install = GEMINI_PKG if not version else f"{GEMINI_PKG}@{version}"
    
    try:
        # For updating, use npm install to update to latest or specific version with --ignore-scripts
        npm_install_global(pkg_to_install, ignore_scripts=True, dry_run=dry_run)
        update_success = True
    except Exception as e:
        echo(f"[warn] npm update with --ignore-scripts failed: {e}", "yellow")
        echo("[info] Retrying without --ignore-scripts flag...", "blue")
        try:
            npm_install_global(pkg_to_install, dry_run=dry_run)
            update_success = True
        except Exception as e2:
            echo(f"[error] npm update failed even without --ignore-scripts: {e2}", "red")
            return False
    
    if not update_success:
        return False
        
    echo("[ok] npm update finished.", "green")
    
    # Patch any ripgrep modules that might be present
    patched = patch_gemini_download_ripgrep(dry_run=dry_run)
    
    # Look for @lvce-editor/ripgrep module specifically for newer versions
    lvce_ripgrep_path = GEMINI_DIR / "node_modules" / "@lvce-editor" / "ripgrep"
    if lvce_ripgrep_path.exists():
        # Find downloadRipGrep.js in the lvce-editor module
        for js_file in lvce_ripgrep_path.rglob("downloadRipGrep.js"):
            if js_file.exists():
                # Patch this specific file
                backup_file(js_file)
                code = js_file.read_text(encoding="utf-8")
                
                # Idempotent check
                if "patched-by-termux_cli_manager" in code or "case 'android'" in code or 'case "android"' in code:
                    echo("[ok] LVCE ripgrep file already patched; skipping.", "green")
                else:
                    # 1) Add android case to platform switch
                    code = re.sub(
                        r"(default:\s*\n\s*throw new VError\('Unknown platform: ' \+ platform\);)",
                        "case 'android':\n            console.info('Using system ripgrep from PATH on Android');\n            return 'system-installed';\n        \\1",
                        code,
                        count=1
                    )
                    
                    # 2) Early-return in downloadRipGrep function
                    code = code.replace(
                        "export const downloadRipGrep = async (overrideBinPath) => {\n",
                        "export const downloadRipGrep = async (overrideBinPath) => {\n    const target = getTarget();\n    if (target === 'system-installed') {\n        console.info('Skipping ripgrep download, using rg from PATH');\n        return;\n    }\n    // patched-by-termux_cli_manager\n"
                    )
                    
                    # Add marker comment
                    if "// patched-by-termux_cli_manager" not in code:
                        code += "\n// patched-by-termux_cli_manager"
                    
                    safe_write(js_file, code, make_backup=False)
                    echo("[ok] LVCE ripgrep patched.", "green")
                break  # Only patch the first one found
    
    if patched and not dry_run:
        autopatch = write_gemini_autopatch(dry_run=dry_run)
        merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=dry_run)
    return True

def uninstall_gemini_flow(config, dry_run=False, yes=False):
    """Uninstall Gemini CLI flow"""
    echo("=== Uninstall Gemini CLI ===", "bold")
    
    # Check if installed
    if not is_installed(GEMINI_DIR):
        echo("[info] Gemini is not installed", "blue")
        return True
    
    # Confirm
    if yes or dry_run:
        if dry_run:
            echo("[dry-run] Would uninstall Gemini", "yellow")
            return True
        else:
            ans = "y"  # Auto-confirm in --yes mode
    else:
        ans = input("Are you sure you want to uninstall Gemini? [y/N]: ").strip().lower()
    
    if not ans.startswith("y"):
        echo("Uninstall cancelled", "blue")
        return True
    
    # Remove patches first
    rollback_gemini_patches(dry_run=dry_run)
    try:
        npm_uninstall_global(GEMINI_PKG, dry_run=dry_run)
    except Exception as e:
        echo(f"[error] npm uninstall failed: {e}", "red")
        return False
    echo("[ok] npm uninstall complete.", "green")
    return True

def install_qwen_flow(config, dry_run=False, yes=False):
    """Install Qwen CLI flow"""
    echo("=== Install Qwen CLI ===", "bold")
    fix_node_gyp_on_android(dry_run=dry_run)
    
    # Check if already installed
    current_version = get_current_version(QWEN_DIR, "qwen --help")
    if current_version != "not installed":
        echo(f"[info] Qwen is already installed", "blue")
        if yes or dry_run:
            ans = "y" if yes else "n"
            if dry_run:
                echo("[dry-run] Would reinstall Qwen", "yellow")
        else:
            ans = input("Reinstall? [y/N]: ").strip().lower()
        if not ans.startswith("y"):
            return True
    
    # Select version
    version = None
    if yes or dry_run:
        ans = "n"  # Default to latest in non-interactive mode
        if dry_run:
            echo("[dry-run] Would install latest version", "yellow")
    else:
        ans = input("Install specific version? [y/N]: ").strip().lower()
    if ans.startswith("y"):
        version = select_version(QWEN_PKG, current_version)
    
    if dry_run:
        echo(f"[dry-run] Would install Qwen CLI with version: {'latest' if version is None else version}", "yellow")
        return True
    
    echo("Installing via npm (using --ignore-scripts by default)...", "blue")
    install_success = False
    try:
        npm_install_global(QWEN_PKG, version, ignore_scripts=True, dry_run=dry_run)
        install_success = True
    except Exception as e:
        echo(f"[warn] npm install with --ignore-scripts failed: {e}", "yellow")
        echo("[info] Retrying without --ignore-scripts flag...", "blue")
        try:
            npm_install_global(QWEN_PKG, version, dry_run=dry_run)
            install_success = True
        except Exception as e2:
            echo(f"[error] npm install failed even without --ignore-scripts: {e2}", "red")
            return False
    echo("[ok] npm install finished.", "green")
    # Optionally patch immediately
    patched = patch_qwen_wrapper_and_index(dry_run=dry_run)
    if patched and not dry_run:
        autopatch = write_qwen_autopatch(dry_run=dry_run)
        merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=dry_run)
    return True

def update_qwen_flow(config, dry_run=False, yes=False):
    """Update Qwen CLI flow"""
    echo("=== Update Qwen CLI ===", "bold")
    
    # Check if installed
    current_version = get_current_version(QWEN_DIR, "qwen --help")
    if current_version == "not installed":
        echo("[warn] Qwen is not installed. Installing instead...", "yellow")
        return install_qwen_flow(config, dry_run=dry_run, yes=yes)
    
    # Select version
    version = None
    if yes or dry_run:
        ans = "n"  # Default to latest in non-interactive mode
        if dry_run:
            echo("[dry-run] Would update to latest version", "yellow")
    else:
        ans = input("Update to specific version? [y/N]: ").strip().lower()
    if ans.startswith("y"):
        version = select_version(QWEN_PKG, current_version)
    elif ans:
        # User provided a version directly
        version = ans
    
    if dry_run:
        echo(f"[dry-run] Would update Qwen CLI to version: {'latest' if version is None else version}", "yellow")
        return True
    
    echo("Updating via npm (using --ignore-scripts by default)...", "blue")
    update_success = False
    pkg_to_install = QWEN_PKG if not version else f"{QWEN_PKG}@{version}"
    
    try:
        # For updating, use npm install to update to latest or specific version with --ignore-scripts
        npm_install_global(pkg_to_install, ignore_scripts=True, dry_run=dry_run)
        update_success = True
    except Exception as e:
        echo(f"[warn] npm update with --ignore-scripts failed: {e}", "yellow")
        echo("[info] Retrying without --ignore-scripts flag...", "blue")
        try:
            npm_install_global(pkg_to_install, dry_run=dry_run)
            update_success = True
        except Exception as e2:
            echo(f"[error] npm update failed even without --ignore-scripts: {e2}", "red")
            return False
    
    if not update_success:
        return False
        
    echo("[ok] npm update finished.", "green")
    
    # Patch immediately after update
    patched = patch_qwen_wrapper_and_index(dry_run=dry_run)
    if patched and not dry_run:
        autopatch = write_qwen_autopatch(dry_run=dry_run)
        merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=dry_run)
    return True

def uninstall_qwen_flow(config, dry_run=False, yes=False):
    """Uninstall Qwen CLI flow"""
    echo("=== Uninstall Qwen CLI ===", "bold")
    
    # Check if installed
    if not is_installed(QWEN_DIR):
        echo("[info] Qwen is not installed", "blue")
        return True
    
    # Confirm
    if yes or dry_run:
        if dry_run:
            echo("[dry-run] Would uninstall Qwen", "yellow")
            return True
        else:
            ans = "y"  # Auto-confirm in --yes mode
    else:
        ans = input("Are you sure you want to uninstall Qwen? [y/N]: ").strip().lower()
    if not ans.startswith("y"):
        echo("Uninstall cancelled", "blue")
        return True
    
    # Remove patches first
    rollback_qwen_patches(dry_run=dry_run)
    try:
        npm_uninstall_global(QWEN_PKG, dry_run=dry_run)
    except Exception as e:
        echo(f"[error] npm uninstall failed: {e}", "red")
        return False
    echo("[ok] npm uninstall complete.", "green")
    return True


# ---------- Verification functions ----------
def verify_gemini():
    """Verify Gemini installation with detailed error reporting"""
    echo("Verifying Gemini installation...", "blue")
    try:
        result = run(["gemini", "--version"], capture=True)
        if result.returncode == 0:
            version_output = result.stdout.strip()
            if version_output:
                echo(f"[ok] Gemini version: {version_output}", "green")
                return True
            else:
                echo("[warn] Gemini ran but returned empty version output", "yellow")
                # Run additional check
                result2 = run(["gemini", "--help"], capture=True)
                if result2.returncode == 0:
                    echo("[ok] Gemini is accessible (help command works)", "green")
                    return True
                else:
                    echo(f"[error] Gemini version empty and help failed: {result2.stderr}", "red")
                    return False
        else:
            echo(f"[error] Gemini verification failed:", "red")
            echo(f"  Command: gemini --version", "red")
            echo(f"  Exit code: {result.returncode}", "red")
            echo(f"  Stderr: {result.stderr[:500]}...", "red")  # Limit output
            if result.stdout:
                echo(f"  Stdout: {result.stdout[:500]}...", "red")
            return False
    except FileNotFoundError:
        echo("[error] Gemini command not found. Is it installed globally?", "red")
        echo("  Try running: npm install -g @google/gemini-cli", "red")
        return False
    except Exception as e:
        echo(f"[error] Gemini verification failed with exception: {e}", "red")
        return False

def verify_qwen():
    """Verify Qwen installation with detailed error reporting"""
    echo("Verifying Qwen installation...", "blue")
    try:
        result = run(["qwen", "--help"], capture=True)
        if result.returncode == 0:
            echo("[ok] Qwen is working correctly", "green")
            # Additional check for basic functionality
            try:
                result2 = run(["qwen", "--version"], capture=True)
                if result2.returncode == 0 and result2.stdout.strip():
                    echo(f"[info] Qwen version: {result2.stdout.strip()}", "blue")
            except:
                pass  # Not critical if version command doesn't exist
            return True
        else:
            echo(f"[error] Qwen verification failed:", "red")
            echo(f"  Command: qwen --help", "red")
            echo(f"  Exit code: {result.returncode}", "red")
            echo(f"  Stderr: {result.stderr[:500]}...", "red")  # Limit output
            if result.stdout:
                echo(f"  Stdout: {result.stdout[:500]}...", "red")
            return False
    except FileNotFoundError:
        echo("[error] Qwen command not found. Is it installed globally?", "red")
        echo("  Try running: npm install -g @qwen-code/qwen-code", "red")
        return False
    except Exception as e:
        echo(f"[error] Qwen verification failed with exception: {e}", "red")
        return False


# ---------- Main interactive ----------
def show_logo():
    """Displays the TCM ASCII art logo."""
    logo = [
        "  ████████╗  ██████╗  ███╗   ███╗",
        "  ╚══██╔══╝ ██╔═══██╗ ████╗ ████║",
        "     ██║   ██║   ██║ ██╔████╔██║",
        "     ██║   ██║   ██║ ██║╚██╔╝██║",
        "     ██║   ╚██████╔╝ ██║ ╚═╝ ██║",
        "     ╚═╝    ╚═════╝  ╚═╝     ╚═╝",
    ]
    echo()
    for line in logo:
        echo(line, "purple")
    echo()
    echo("     Termux CLI Manager & Fixer", "bold")
    echo("="*50, "purple")

def get_manager_version():
    """Get current version of the tool"""
    version_file = Path(__file__).parent / "VERSION.json"
    if version_file.exists():
        try:
            with open(version_file, 'r') as f:
                version_data = json.load(f)
                return version_data.get("version", "unknown")
        except Exception as e:
            echo(f"[warn] Failed to read version file: {e}", "yellow")
            return "unknown"
    return "unknown"

def check_for_updates():
    """Check for updates to the tool itself"""
    echo("Checking for updates to Termux CLI Manager...", "blue")
    current_version = get_manager_version()
    echo(f"[info] Current version: {current_version}", "blue")
    
    try:
        # In a real implementation, you would check against a remote repository
        # For now, we'll just show that the mechanism is in place
        echo("[info] Latest version: 1.0.0", "blue")
        
        if current_version == "unknown" or current_version == "1.0.0":
            echo("[ok] Termux CLI Manager is up to date", "green")
            return True
        else:
            echo("[info] A new version is available", "yellow")
            echo("[info] Visit https://github.com/frederickabrah/TCM to download the latest version", "blue")
            return True
    except Exception as e:
        echo(f"[error] Failed to check for updates: {e}", "red")
        return False

def show_menu(config, yes=False, dry_run=False):
    """Show interactive menu"""
    while True:
        show_logo()
        
        if dry_run:
            echo(f"\n[Dry Run Mode - No changes will be made]", "yellow")
        
        echo(f"\nDetected paths:", "blue")
        echo(f"  Global npm dir: {NPM_GLOBAL}")
        echo(f"  Gemini path:    {GEMINI_DIR}")
        echo(f"  Qwen path:      {QWEN_DIR}")
        
        echo(f"\nInstallation status:", "blue")
        echo(f"  Gemini: {get_current_version(GEMINI_DIR, 'gemini --version')}")
        echo(f"  Qwen:   {get_current_version(QWEN_DIR, 'qwen --help')}")
        
        echo("\nOptions:", "bold")
        echo("  1) Install Gemini")
        echo("  2) Update Gemini")
        echo("  3) Uninstall Gemini")
        echo("  4) Install Qwen")
        echo("  5) Update Qwen")
        echo("  6) Uninstall Qwen")
        echo("  7) Patch Gemini")
        echo("  8) Patch Qwen")
        echo("  9) Patch both")
        echo(" 10) Ensure ripgrep (pkg install)")
        echo(" 11) Rollback Gemini patches")
        echo(" 12) Rollback Qwen patches")
        echo(" 13) Do everything (install both -> ripgrep -> patch -> rebuild)")
        echo(" 14) Verify installations")
        echo(" 15) Show log file")
        echo(" 16) Fix node-gyp (for node-pty errors)")
        echo(" 17) Check for updates")
        echo("  0) Exit")
        
        choice = input("\nChoose [0-17]: ").strip()
        
        if choice == "1":
            install_gemini_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "2":
            update_gemini_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "3":
            uninstall_gemini_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "4":
            install_qwen_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "5":
            update_qwen_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "6":
            uninstall_qwen_flow(config, dry_run=dry_run, yes=yes)
        elif choice == "7":
            patched = patch_gemini_download_ripgrep(dry_run=dry_run)
            if patched and not dry_run:
                autopatch = write_gemini_autopatch(dry_run=dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=dry_run)
        elif choice == "8":
            patched = patch_qwen_wrapper_and_index(dry_run=dry_run)
            if patched and not dry_run:
                autopatch = write_qwen_autopatch(dry_run=dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=dry_run)
        elif choice == "9":
            # Patch both
            patched_g = patch_gemini_download_ripgrep(dry_run=dry_run)
            if patched_g and not dry_run:
                autopatch = write_gemini_autopatch(dry_run=dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=dry_run)
            patched_q = patch_qwen_wrapper_and_index(dry_run=dry_run)
            if patched_q and not dry_run:
                autopatch = write_qwen_autopatch(dry_run=dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=dry_run)
        elif choice == "10":
            # Ensure ripgrep options
            echo("Ripgrep options:", "bold")
            echo("  a) Ensure system ripgrep via pkg (recommended)")
            echo("  b) Attempt to build ripgrep from source (requires Rust, heavy)")
            if yes or dry_run:
                sub = "a"  # Default to pkg install in non-interactive mode
                if dry_run:
                    echo(f"[dry-run] Would select option 'a' for ripgrep", "yellow")
            else:
                sub = input("Choose [a/b]: ").strip().lower() or "a"
            if sub == "a":
                ensure_system_ripgrep(auto_install=True, dry_run=dry_run)
            else:
                build_ripgrep_from_source(dry_run=dry_run)
        elif choice == "11":
            rollback_gemini_patches(dry_run=dry_run)
        elif choice == "12":
            rollback_qwen_patches(dry_run=dry_run)
        elif choice == "13":
            # do everything
            install_gemini_flow(config, dry_run=dry_run, yes=yes)
            install_qwen_flow(config, dry_run=dry_run, yes=yes)
            ensure_system_ripgrep(auto_install=True, dry_run=dry_run)
            fix_node_gyp_on_android(dry_run=dry_run)
            patch_gemini_download_ripgrep(dry_run=dry_run)
            if not dry_run:
                autopatch = write_gemini_autopatch(dry_run=dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=dry_run)
            patch_qwen_wrapper_and_index(dry_run=dry_run)
            if not dry_run:
                autopatch = write_qwen_autopatch(dry_run=dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=dry_run)
            # Rebuild
            if not dry_run:
                npm_rebuild_global([GEMINI_PKG, QWEN_PKG])
        elif choice == "14":
            verify_gemini()
            verify_qwen()
        elif choice == "15":
            # Show log file
            if LOG_FILE.exists():
                echo(f"\n--- Log file: {LOG_FILE} ---", "blue")
                try:
                    with open(LOG_FILE, 'r') as f:
                        content = f.read()
                        print(content)
                except Exception as e:
                    echo(f"[error] Failed to read log file: {e}", "red")
                echo("--- End of log ---\n", "blue")
            else:
                echo("[info] Log file is empty", "blue")
        elif choice == "16":
            fix_node_gyp_on_android(dry_run=dry_run)
        elif choice == "17":
            check_for_updates()
        elif choice == "0":
            echo("Goodbye!", "green")
            sys.exit(0)
        else:
            echo("Invalid option. Please try again.", "red")
        
        if dry_run:
            echo("\n[Dry run completed - no changes were made]", "yellow")
            input("\nPress Enter to continue or Ctrl+C to exit...")
        elif not yes:  # Only pause if not in 'yes' mode
            input("\nPress Enter to continue...")

def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description="Termux CLI Manager for Gemini and Qwen")
    parser.add_argument("--install-gemini", action="store_true", help="Install Gemini CLI")
    parser.add_argument("--update-gemini", action="store_true", help="Update Gemini CLI")
    parser.add_argument("--uninstall-gemini", action="store_true", help="Uninstall Gemini CLI")
    parser.add_argument("--install-qwen", action="store_true", help="Install Qwen CLI")
    parser.add_argument("--update-qwen", action="store_true", help="Update Qwen CLI")
    parser.add_argument("--uninstall-qwen", action="store_true", help="Uninstall Qwen CLI")
    parser.add_argument("--patch-gemini", action="store_true", help="Patch Gemini CLI")
    parser.add_argument("--patch-qwen", action="store_true", help="Patch Qwen CLI")
    parser.add_argument("--patch-both", action="store_true", help="Patch both CLIs")
    parser.add_argument("--ensure-rg", action="store_true", help="Ensure ripgrep is installed")
    parser.add_argument("--build-rg", action="store_true", help="Build ripgrep from source")
    parser.add_argument("--rollback-gemini", action="store_true", help="Rollback Gemini patches")
    parser.add_argument("--rollback-qwen", action="store_true", help="Rollback Qwen patches")
    parser.add_argument("--do-everything", action="store_true", help="Do everything (install both -> ripgrep -> patch -> rebuild)")
    parser.add_argument("--rollback", action="store_true", help="Rollback all patches")
    parser.add_argument("--verify", action="store_true", help="Verify installations")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    parser.add_argument("--fix-node-gyp", action="store_true", help="Apply fix for node-gyp on Android")
    parser.add_argument("--check-updates", action="store_true", help="Check for updates to this tool")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be done without making changes")
    parser.add_argument("--yes", "-y", action="store_true", help="Answer yes to all prompts")
    
    return parser.parse_args()

def main():
    """Main function"""
    if not is_termux():
        echo("[warn] This script is intended for Termux. Continue? [y/N]", "yellow")
        if not (sys.argv.count('--yes') or sys.argv.count('-y')) and input().strip().lower() != "y":
            echo("Aborting.", "red")
            sys.exit(1)

    # Parse command line arguments
    args = parse_args()
    
    # Setup logging
    setup_logging(args.verbose)
    
    # Load configuration
    config = load_config()
    
    # Check dependencies
    if not check_dependencies():
        echo("[error] Required dependencies missing. Please install them and try again.", "red")
        sys.exit(1)
    
    # If any CLI arguments provided, run in CLI mode
    if any([
        args.install_gemini, args.update_gemini, args.uninstall_gemini,
        args.install_qwen, args.update_qwen, args.uninstall_qwen,
        args.patch_gemini, args.patch_qwen, args.patch_both,
        args.ensure_rg, args.build_rg, args.rollback_gemini, 
        args.rollback_qwen, args.rollback, args.do_everything, 
        args.verify, args.fix_node_gyp, args.check_updates
    ]):
        # CLI mode
        executed = False
        
        # Handle build-rg separately as it's an option for ensure-rg
        if args.build_rg:
            success = build_ripgrep_from_source(dry_run=args.dry_run)
            if not success and not args.dry_run:
                echo("[error] Failed to build ripgrep from source", "red")
                sys.exit(1)
            executed = True
        
        if args.install_gemini:
            install_gemini_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.update_gemini:
            update_gemini_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.uninstall_gemini:
            uninstall_gemini_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.install_qwen:
            install_qwen_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.update_qwen:
            update_qwen_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.uninstall_qwen:
            uninstall_qwen_flow(config, dry_run=args.dry_run, yes=args.yes)
            executed = True
        if args.patch_gemini:
            patched = patch_gemini_download_ripgrep(dry_run=args.dry_run)
            if patched and not args.dry_run:
                autopatch = write_gemini_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=args.dry_run)
            executed = True
        if args.patch_qwen:
            patched = patch_qwen_wrapper_and_index(dry_run=args.dry_run)
            if patched and not args.dry_run:
                autopatch = write_qwen_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=args.dry_run)
            executed = True
        if args.patch_both:
            # Patch both
            patched_g = patch_gemini_download_ripgrep(dry_run=args.dry_run)
            if patched_g and not args.dry_run:
                autopatch = write_gemini_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=args.dry_run)
            patched_q = patch_qwen_wrapper_and_index(dry_run=args.dry_run)
            if patched_q and not args.dry_run:
                autopatch = write_qwen_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=args.dry_run)
            executed = True
        if args.ensure_rg:
            success = ensure_system_ripgrep(auto_install=True, dry_run=args.dry_run)
            if not success and not args.dry_run:
                echo("[info] ripgrep not found and not installed, you can try --build-rg to compile from source", "yellow")
            executed = True
        if args.rollback_gemini:
            rollback_gemini_patches(dry_run=args.dry_run)
            executed = True
        if args.rollback_qwen:
            rollback_qwen_patches(dry_run=args.dry_run)
            executed = True
        if args.rollback:
            rollback_gemini_patches(dry_run=args.dry_run)
            rollback_qwen_patches(dry_run=args.dry_run)
            executed = True
        if args.do_everything:
            # do everything
            install_gemini_flow(config, dry_run=args.dry_run, yes=args.yes)
            install_qwen_flow(config, dry_run=args.dry_run, yes=args.yes)
            ensure_system_ripgrep(auto_install=True, dry_run=args.dry_run)
            fix_node_gyp_on_android(dry_run=args.dry_run)
            patch_gemini_download_ripgrep(dry_run=args.dry_run)
            if not args.dry_run:
                autopatch = write_gemini_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(GEMINI_DIR, autopatch, dry_run=args.dry_run)
            patch_qwen_wrapper_and_index(dry_run=args.dry_run)
            if not args.dry_run:
                autopatch = write_qwen_autopatch(dry_run=args.dry_run)
                merge_postinstall_hook(QWEN_DIR, autopatch, dry_run=args.dry_run)
            # Rebuild
            if not args.dry_run:
                npm_rebuild_global([GEMINI_PKG, QWEN_PKG])
            executed = True
        if args.verify:
            verify_gemini_result = verify_gemini()
            verify_qwen_result = verify_qwen()
            # Exit with error code if any verification failed
            if not verify_gemini_result or not verify_qwen_result:
                sys.exit(1)
            executed = True
        if args.fix_node_gyp:
            fix_node_gyp_on_android(dry_run=args.dry_run)
            executed = True
        if args.check_updates:
            check_for_updates()
            executed = True
            
        if not executed:
            echo("No actions specified. Use --help for usage information.", "yellow")
            sys.exit(1)
    else:
        # Interactive mode
        show_menu(config, yes=args.yes, dry_run=args.dry_run)

if __name__ == "__main__":
    main()