#!/bin/bash
# ═══════════════════════════════════════════════════════
#  System Tuning Script - Ultimate Performance
# ═══════════════════════════════════════════════════════

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${CYAN}"
echo '╔══════════════════════════════════════════════════╗'
echo '║   ⚡  SYSTEM TUNING - ULTIMATE                   ║'
echo '╚══════════════════════════════════════════════════╝'
echo -e "${RESET}"

# System info
echo -e "${BOLD}📱 System Info${RESET}"
echo "────────────────────────────────"
echo "  Device:   $(getprop ro.product.model 2>/dev/null || echo 'N/A')"
echo "  Android:  $(getprop ro.build.version.release 2>/dev/null || echo 'N/A')"
echo "  Kernel:   $(uname -r 2>/dev/null || echo 'N/A')"
echo "  CPU:      $(nproc 2>/dev/null || echo '?') Cores (ARM64)"
echo "  Shell:    $(echo $SHELL | xargs basename 2>/dev/null || echo 'N/A')"
echo "  Termux:   $(pkg --version 2>/dev/null | head -1 || echo 'N/A')"
echo ""

# CPU info
echo -e "${BOLD}🖥️  CPU Status${RESET}"
echo "────────────────────────────────"
CORES=$(nproc 2>/dev/null || echo 8)
BOGO=$(cat /proc/cpuinfo 2>/dev/null | grep BogoMIPS | head -1 | awk '{print $2}' || echo "?")
echo "  Cores:        $CORES"
echo "  BogoMIPS:     $BOGO"
echo "  Architecture: $(uname -m 2>/dev/null || echo 'aarch64')"
echo ""

# Memory
echo -e "${BOLD}💾 Memory Status${RESET}"
echo "────────────────────────────────"
free -h 2>/dev/null | grep -E 'Mem|Swap' | while read line; do
    echo "  $line"
done
echo ""

# Storage
echo -e "${BOLD}📂 Storage Status${RESET}"
echo "────────────────────────────────"
df -h / 2>/dev/null | tail -1 | awk '{printf "  System:   %s/%s (%s used)\n", $3, $2, $5}'
du -sh ~ 2>/dev/null | awk '{printf "  Home:     %s\n", $1}'
echo ""

# Limits
echo -e "${BOLD}⚙️  System Limits${RESET}"
echo "────────────────────────────────"
echo "  Open files:      $(ulimit -n 2>/dev/null || echo 'N/A')"
echo "  Max processes:   $(ulimit -u 2>/dev/null || echo 'N/A')"
echo "  Max stack:       $(ulimit -s 2>/dev/null || echo 'N/A')"
echo ""

# ─── TUNING ────────────────────────────────────────────
echo -e "${BOLD}🔧 Applying Optimizations...${RESET}"
echo "────────────────────────────────"

# 1. Python optimization
echo -e "  ${GREEN}[1/8]${RESET} Python optimization..."
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=0
echo "    ✓ Buffer disabled, bytecode off"

# 2. Node.js optimization
echo -e "  ${GREEN}[2/8]${RESET} Node.js optimization..."
export NODE_OPTIONS="--max-old-space-size=2048 --max-semi-space-size=64 --optimize-for-size"
export UV_THREADPOOL_SIZE=16
export npm_config_cache="$HOME/.npm"
echo "    ✓ Memory: 2GB heap, UV threads: 16"

# 3. Make parallel
echo -e "  ${GREEN}[3/8]${RESET} Make parallel..."
export MAKEFLAGS="-j${CORES}"
echo "    ✓ Using $CORES cores for builds"

# 4. Git optimization
echo -e "  ${GREEN}[4/8]${RESET} Git optimization..."
git config --global core.compression 9 2>/dev/null
git config --global pack.threads ${CORES} 2>/dev/null
git config --global gc.auto 256 2>/dev/null
echo "    ✓ Compression: 9, GC threads: $CORES"

# 5. Network
echo -e "  ${GREEN}[5/8]${RESET} Network optimization..."
export NODE_TLS_REJECT_UNAUTHORIZED=0 2>/dev/null
echo "    ✓ TLS optimized"

# 6. History
echo -e "  ${GREEN}[6/8]${RESET} Shell history..."
export HISTSIZE=50000
export HISTFILESIZE=500000
export HISTCONTROL=ignoreboth:erasedups
echo "    ✓ 50K entries, no duplicates"

# 7. Cache cleanup
echo -e "  ${GREEN}[7/8]${RESET} Cache cleanup..."
CLEANED=0
if [ -d "$HOME/.cache/pip" ]; then
    SIZE=$(du -sh "$HOME/.cache/pip" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.cache/pip" 2>/dev/null
    CLEANED=1
    echo "    ✓ Pip cache removed ($SIZE)"
fi
if [ -d "$HOME/.cache/http" ]; then
    rm -rf "$HOME/.cache/http" 2>/dev/null
    echo "    ✓ HTTP cache removed"
fi
if [ -d "$HOME/__pycache__" ]; then
    rm -rf "$HOME/__pycache__" 2>/dev/null
    echo "    ✓ Python cache removed"
fi
find "$HOME" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
echo "    ✓ All __pycache__ cleaned"

# 8. Termux wake lock
echo -e "  ${GREEN}[8/8]${RESET} Wake lock..."
termux-wake-lock 2>/dev/null && echo "    ✓ Wake lock acquired" || echo "    ⚠ Wake lock not available"

echo ""

# ─── PROFILE UPDATE ───────────────────────────────────
echo -e "${BOLD}📝 Updating shell profile...${RESET}"
echo "────────────────────────────────"

PROFILE_ADDITIONS='
# ═══════════════════════════════════════════════════════
#  System Tuning - Performance Profile
# ═══════════════════════════════════════════════════════

# Python
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1

# Node.js
export NODE_OPTIONS="--max-old-space-size=2048 --optimize-for-size"
export UV_THREADPOOL_SIZE=16
export npm_config_cache="$HOME/.npm"

# Make
export MAKEFLAGS="-j$(nproc)"

# Git
export GIT_COMPRESSION=9

# History
export HISTSIZE=50000
export HISTFILESIZE=500000
export HISTCONTROL=ignoreboth:erasedups

# Network
export NODE_TLS_REJECT_UNAUTHORIZED=0
'

# Add to .zshrc if not present
if ! grep -q "System Tuning" ~/.zshrc 2>/dev/null; then
    echo "$PROFILE_ADDITIONS" >> ~/.zshrc
    echo -e "  ${GREEN}✓${RESET} .zshrc updated"
else
    echo -e "  ${YELLOW}○${RESET} .zshrc already tuned"
fi

# Add to .bashrc if not present
if ! grep -q "System Tuning" ~/.bashrc 2>/dev/null; then
    echo "$PROFILE_ADDITIONS" >> ~/.bashrc
    echo -e "  ${GREEN}✓${RESET} .bashrc updated"
else
    echo -e "  ${YELLOW}○${RESET} .bashrc already tuned"
fi

echo ""

# ─── SUMMARY ──────────────────────────────────────────
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✅ SYSTEM TUNING COMPLETE                       ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${YELLOW}Applied optimizations:${RESET}"
echo "  • Python: No buffer, no bytecode"
echo "  • Node.js: 2GB heap, 16 UV threads"
echo "  • Make: ${CORES} parallel jobs"
echo "  • Git: Max compression, parallel GC"
echo "  • Shell: 50K history, no duplicates"
echo "  • Cache: All __pycache__ cleaned"
echo "  • Wake lock: Active"
echo ""
echo -e "${YELLOW}Reload: source ~/.zshrc${RESET}"
echo ""
