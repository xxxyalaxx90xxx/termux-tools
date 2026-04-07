#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Install Script - Setup all Termux Tools
# ═══════════════════════════════════════════════════════

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${CYAN}"
echo '╔══════════════════════════════════════════════════╗'
echo '║   🔧  TERMUX TOOLS INSTALLER                     ║'
echo '╚══════════════════════════════════════════════════╝'
echo -e "${RESET}"

# Check Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}Error: This script requires Termux on Android${RESET}"
    exit 1
fi

# Update
echo -e "${BLUE}[1/5]${RESET} Updating packages..."
pkg update -y -q 2>/dev/null

# Install dependencies
echo -e "${BLUE}[2/5]${RESET} Installing dependencies..."
pkg install -y -q \
    nano vim tree curl openssl sqlite \
    python3 git gh jq 2>/dev/null

# Setup directories
echo -e "${BLUE}[3/5]${RESET} Creating directories..."
mkdir -p ~/.shortcuts/tasks ~/.notes ~/.writer_backups

# Copy scripts
echo -e "${BLUE}[4/5]${RESET} Installing scripts..."
SCRIPTS=(
    ".writer.sh"
    ".startpage.sh"
    "ai-bot.py"
    "ai-dashboard.sh"
    "ai-hub.sh"
    "T-setup.sh"
    "phone-tune.sh"
    "speed-boost.sh"
    "download-models.sh"
    "matrix-rain.py"
    "termux_cli_manager.py"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        cp "$script" "$HOME/$script"
        chmod +x "$HOME/$script"
        echo -e "  ${GREEN}✓${RESET} $script"
    else
        echo -e "  ${YELLOW}○${RESET} $script (not found, skipping)"
    fi
done

# Setup aliases
echo -e "${BLUE}[5/5]${RESET} Setting up aliases..."

# Zsh aliases
if ! grep -q "alias writer=" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'

# Termux Tools
alias writer='bash ~/.writer.sh'
alias w='bash ~/.writer.sh'
alias startpage='bash ~/.startpage.sh'
alias matrix-rain='python3 ~/matrix-rain.py'
alias phone-tune='bash ~/phone-tune.sh'
alias speed-boost='bash ~/speed-boost.sh'
alias ai-dash='bash ~/ai-dashboard.sh'
alias ai-hub='bash ~/ai-hub.sh'
alias tcm='python3 ~/termux_cli_manager.py'
EOF
    echo -e "  ${GREEN}✓${RESET} Zsh aliases added"
fi

# Bash aliases
if ! grep -q "alias writer=" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# Termux Tools
alias writer='bash ~/.writer.sh'
alias w='bash ~/.writer.sh'
alias startpage='bash ~/.startpage.sh'
alias matrix-rain='python3 ~/matrix-rain.py'
alias phone-tune='bash ~/phone-tune.sh'
alias speed-boost='bash ~/speed-boost.sh'
alias ai-dash='bash ~/ai-dashboard.sh'
alias ai-hub='bash ~/ai-hub.sh'
alias tcm='python3 ~/termux_cli_manager.py'
EOF
    echo -e "  ${GREEN}✓${RESET} Bash aliases added"
fi

# Create bin directory
mkdir -p ~/.local/bin
if [ ! -f "$HOME/.local/bin/writer" ]; then
    cat > ~/.local/bin/writer << 'EOF'
#!/bin/bash
exec bash ~/.writer.sh "$@"
EOF
    chmod +x ~/.local/bin/writer
    echo -e "  ${GREEN}✓${RESET} Writer binary installed"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✅ Installation complete!                       ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${YELLOW}Next steps:${RESET}"
echo "  source ~/.zshrc    # Reload shell"
echo "  startpage          # Open startpage"
echo "  writer             # Use Writer Tool"
echo "  tcm                # Open CLI Manager"
echo ""
