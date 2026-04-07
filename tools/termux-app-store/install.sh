#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

APP_NAME="termux-app-store"
REPO="djunekz/termux-app-store"
INSTALL_DIR="$PREFIX/lib/.tas"
BIN_DIR="$PREFIX/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

R=$'\033[0m'
B=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'

die()  { printf "\n %s[✗]%s %s\n" "$RED$B" "$R" "$*" >&2; exit 1; }
info() { printf " %s[*]%s %s\n" "$CYAN$B" "$R" "$*"; }
ok()   { printf " %s[✓]%s %s\n" "$GREEN$B" "$R" "$*"; }
warn() { printf " %s[!]%s %s\n" "$YELLOW$B" "$R" "$*"; }

fetch_latest_version() {
  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    "$GITHUB_API" 2>/dev/null \
    | grep '"tag_name"' \
    | head -1 \
    | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' \
    | sed 's/^v//'
}

detect_version() {
  local ver=""

  if [[ -f "$INSTALL_DIR/.installed" ]]; then
    ver=$(grep '^version=' "$INSTALL_DIR/.installed" 2>/dev/null | cut -d= -f2 || true)
  fi

  if [[ -z "$ver" ]]; then
    for f in \
      "$INSTALL_DIR/termux_app_store/main.py" \
      "$INSTALL_DIR/termux_app_store/termux_app_store_cli.py" \
      "$SCRIPT_DIR/termux_app_store/main.py" \
      "$SCRIPT_DIR/termux_app_store/termux_app_store_cli.py"; do
      if [[ -f "$f" ]]; then
        ver=$(grep -oP 'APP_VERSION\s*=\s*"\K[0-9.]+' "$f" 2>/dev/null | head -1 || true)
        [[ -n "$ver" ]] && break
      fi
    done
  fi

  if [[ -z "$ver" ]]; then
    ver=$(fetch_latest_version 2>/dev/null || true)
  fi

  echo "${ver:-unknown}"
}

check_termux() {
  command -v pkg >/dev/null 2>&1 || die "This installer must be run inside Termux"
  ok "Running in Termux environment"
}

install_dep() {
  local dep="$1"
  if command -v "$dep" >/dev/null 2>&1; then
    ok "Dependency satisfied: $dep"
  else
    info "Installing: $dep"
    pkg install -y "$dep" || die "Failed to install $dep"
    ok "$dep installed"
  fi
}

detect_arch() {
  local arch; arch="$(uname -m)"
  case "$arch" in
    aarch64)       BIN_ARCH="aarch64" ;;
    armv7l|armv8l) BIN_ARCH="arm" ;;
    x86_64)        BIN_ARCH="x86_64" ;;
    i686)          BIN_ARCH="i686" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac
  ok "Architecture: ${B}$arch${R}"
}

detect_mode() {
  if [[ -f "$SCRIPT_DIR/termux_app_store/termux_app_store_cli.py" ]] && \
     [[ -f "$SCRIPT_DIR/termux_app_store/main.py" ]] && \
     [[ -f "$SCRIPT_DIR/tools/package_manager.py" ]]; then
    INSTALL_MODE="source"
    ok "Installation mode: ${B}Source${R}"
  else
    INSTALL_MODE="binary"
    ok "Installation mode: ${B}Binary${R}"
  fi
}

check_existing() {
  [[ -f "$BIN_DIR/$APP_NAME" ]] || [[ -d "$INSTALL_DIR" ]] || return 0

  warn "Existing installation found"
  local current
  current=$(detect_version)
  printf "  Current version : %sv%s%s\n" "$B" "$current" "$R"
  printf "  Overwrite? [Y/n]: "
  read -r resp
  case "$resp" in
    [nN]|[nN][oO]) die "Installation cancelled" ;;
  esac
}

cleanup() {
  info "Cleaning up old installation..."
  rm -rf "$INSTALL_DIR"
  rm -f  "$BIN_DIR/$APP_NAME"
}

install_source() {
  if ! command -v python3 >/dev/null 2>&1; then
    info "Installing Python3..."
    pkg install -y python || die "Failed to install Python3"
  fi
  ok "Python: $(python3 --version 2>&1 | awk '{print $2}')"

  if ! python3 -m pip --version >/dev/null 2>&1; then
    info "Installing pip..."
    pkg install -y python-pip || die "Failed to install pip"
  fi
  ok "pip: $(python3 -m pip --version | awk '{print $1,$2}')"

  if ! python3 -c "import textual" >/dev/null 2>&1; then
    info "Installing Textual..."
    python3 -m pip install textual --break-system-packages || die "Failed to install Textual"
  fi
  ok "Textual: v$(python3 -c "import textual; print(textual.__version__)" 2>/dev/null)"

  info "Copying files to $INSTALL_DIR ..."
  mkdir -p "$INSTALL_DIR/termux_app_store"
  cp -r "$SCRIPT_DIR/termux_app_store/"* "$INSTALL_DIR/termux_app_store/"

  if [[ -d "$SCRIPT_DIR/tools" ]]; then
    cp -r "$SCRIPT_DIR/tools" "$INSTALL_DIR/"
  fi

  if [[ -d "$SCRIPT_DIR/packages" ]]; then
    cp -r "$SCRIPT_DIR/packages" "$INSTALL_DIR/"
    ok "Packages directory copied"
  fi

  if [[ -f "$SCRIPT_DIR/build-package.sh" ]]; then
    cp "$SCRIPT_DIR/build-package.sh" "$INSTALL_DIR/"
  fi

  ok "Files copied"
}

_fallback_source() {
  if [[ ! -f "$SCRIPT_DIR/termux_app_store/termux_app_store_cli.py" ]]; then
    install_dep "git"
    local tmp_repo
    tmp_repo=$(mktemp -d)
    info "Cloning repository for source install..."
    git clone --depth=1 "https://github.com/$REPO.git" "$tmp_repo" || \
      die "Failed to clone repository"
    SCRIPT_DIR="$tmp_repo"
  fi
  install_source
}

install_binary() {
  install_dep "curl"
  install_dep "file"

  local bin_name="termux-app-store-${BIN_ARCH}"
  local tag
  info "Fetching latest release info..."
  tag=$(fetch_latest_version)
  [[ -n "$tag" ]] || die "Cannot fetch release info. Check your internet connection."

  local url="https://github.com/$REPO/releases/download/v${tag}/$bin_name"
  local target="$INSTALL_DIR/$bin_name.bin"

  mkdir -p "$INSTALL_DIR"
  info "Downloading ${B}$bin_name v${tag}${R}..."

  curl -fL --progress-bar --retry 3 --retry-delay 2 "$url" -o "$target" 2>&1
  local curl_exit=$?

  if [[ $curl_exit -ne 0 ]]; then
    warn "Binary download failed, falling back to source install"
    rm -f "$target"
    INSTALL_MODE="source"
    _fallback_source
    return
  fi

  if ! file "$target" 2>/dev/null | grep -q ELF; then
    warn "Downloaded file is not a valid ELF binary, falling back to source install"
    rm -f "$target"
    INSTALL_MODE="source"
    _fallback_source
    return
  fi

  chmod +x "$target"
  ln -sf "$target" "$INSTALL_DIR/$APP_NAME"
  ok "Binary downloaded and validated"
}

write_sentinel() {
  cat > "$INSTALL_DIR/.installed" << EOF
version=$1
mode=$INSTALL_MODE
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
  ok "Saved install info: $INSTALL_DIR/.installed"
}

create_wrapper() {
  info "Creating wrapper script..."

  local ver
  ver=$(detect_version)

  {
    printf '#!/data/data/com.termux/files/usr/bin/bash\n'
    printf 'export TERMUX_APP_STORE_VERSION="%s"\n' "$ver"
    printf 'export TERMUX_APP_STORE_HOME="%s"\n' "$INSTALL_DIR"
    printf '\n'
    if [[ "$INSTALL_MODE" == "source" ]]; then
      printf 'exec python3 "%s/termux_app_store/main.py" "$@"\n' "$INSTALL_DIR"
    else
      printf 'exec "%s/%s" "$@"\n' "$INSTALL_DIR" "$APP_NAME"
    fi
  } > "$BIN_DIR/$APP_NAME"

  chmod +x "$BIN_DIR/$APP_NAME"
  ok "Wrapper created: $BIN_DIR/$APP_NAME"
}

show_done() {
  local ver
  ver=$(detect_version)

  printf "\n%s╔══════════════════════════════════════════╗%s\n" "$GREEN$B" "$R"
  printf   "%s║   Installation Completed Successfully!   ║%s\n" "$GREEN$B" "$R"
  printf   "%s╚══════════════════════════════════════════╝%s\n" "$GREEN$B" "$R"
  printf "\n%sDetails:%s\n" "$CYAN$B" "$R"
  printf "  Version   : %sv%s%s\n" "$B" "$ver" "$R"
  printf "  Mode      : %s%s%s\n" "$B" "$INSTALL_MODE" "$R"
  printf "  Installed : %s%s/%s%s\n" "$DIM" "$BIN_DIR" "$APP_NAME" "$R"
  printf "\n%sManage with tasctl:%s\n" "$CYAN$B" "$R"
  printf "  ./tasctl update    %s→ Update to latest%s\n" "$DIM" "$R"
  printf "  ./tasctl uninstall %s→ Remove%s\n" "$DIM" "$R"
  printf "  ./tasctl doctor    %s→ Diagnose environment%s\n\n" "$DIM" "$R"
}

main() {
  printf "\n%s╔═════════════════════════════════════════════╗%s\n" "$CYAN$B" "$R"
  printf   "%s║         Termux App Store Installer          ║%s\n" "$CYAN$B" "$R"
  printf   "%s║ https://github.com/djunekz/termux-app-store ║%s\n" "$CYAN$B" "$R"
  printf   "%s║               by @djunekz                   ║%s\n" "$CYAN$B" "$R"
  printf   "%s╚═════════════════════════════════════════════╝%s\n\n" "$CYAN$B" "$R"

  check_termux
  detect_arch
  detect_mode
  check_existing
  printf "\n"
  cleanup

  if [[ "$INSTALL_MODE" == "source" ]]; then
    install_source
  else
    install_binary
  fi

  local ver
  ver=$(detect_version)
  write_sentinel "$ver"
  create_wrapper
  show_done
}

trap 'printf "\n"; die "Installation failed at line $LINENO"' ERR

main "$@"
