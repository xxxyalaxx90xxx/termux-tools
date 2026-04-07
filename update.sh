#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Update Script - Pull latest versions from GitHub
# ═══════════════════════════════════════════════════════

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${CYAN}Updating Termux Tools...${RESET}"

# Check if repo exists
REPO_DIR="$HOME/termux-tools"

if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    echo -e "${BLUE}Pulling latest changes...${RESET}"
    git pull origin main 2>&1
else
    echo -e "${BLUE}Cloning repository...${RESET}"
    git clone https://github.com/xxxyalaxx90xxx/termux-tools.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Copy scripts to home
echo -e "${BLUE}Installing scripts...${RESET}"
for script in *.sh *.py .*.sh .*.py; do
    [ -f "$script" ] || continue
    cp "$script" "$HOME/$script"
    chmod +x "$HOME/$script"
    echo -e "  ${GREEN}✓${RESET} $script"
done

# Create binary wrapper
mkdir -p ~/.local/bin
cat > ~/.local/bin/writer << 'EOF'
#!/bin/bash
exec bash ~/.writer.sh "$@"
EOF
chmod +x ~/.local/bin/writer

echo ""
echo -e "${GREEN}✅ Update complete!${RESET}"
echo -e "${YELLOW}Run: source ~/.zshrc${RESET}"
