#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Install ALL Downloaded GitHub Tools
# ═══════════════════════════════════════════════════════

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

INSTALLED="$HOME/installed-tools"
DOWNLOADED="$HOME/github-tools"
mkdir -p "$INSTALLED"

echo -e "${CYAN}"
echo '╔══════════════════════════════════════════════════╗'
echo '║   📦  INSTALLING ALL DOWNLOADED TOOLS            ║'
echo '╚══════════════════════════════════════════════════╝'
echo -e "${RESET}"

COUNT=0
for dir in "$DOWNLOADED"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    
    # Skip .git dirs
    [ "$name" = ".git" ] && continue
    
    echo -ne "  ${BOLD}[$((COUNT+1))]${RESET} ${name}... "
    
    # Remove old version if exists
    rm -rf "$INSTALLED/$name" 2>/dev/null
    
    # Remove nested .git dirs
    find "$dir" -name ".git" -type d -exec rm -rf {} + 2>/dev/null
    
    # Copy
    cp -r "$dir" "$INSTALLED/" 2>/dev/null
    
    if [ -d "$INSTALLED/$name" ]; then
        SIZE=$(du -sh "$INSTALLED/$name" 2>/dev/null | cut -f1)
        echo -e "${GREEN}✓ Installed ($SIZE)${RESET}"
        COUNT=$((COUNT+1))
    else
        echo -e "${RED}✗ Failed${RESET}"
    fi
done

echo ""
echo -e "${BOLD}📝 Adding aliases...${RESET}"

# Add aliases for all new tools
cat >> ~/.bashrc << 'EOF'

# All Installed Tools Aliases
alias eternity='ls ~/installed-tools/eternity 2>/dev/null'
alias misha-tools='ls ~/installed-tools/misha-tools 2>/dev/null'
alias tool-x='bash ~/installed-tools/Tool-X/Tool-X.sh 2>/dev/null'
alias pyphisher='bash ~/installed-tools/pyphisher/pyphisher.sh 2>/dev/null'
alias termux-app='ls ~/installed-tools/termux-app 2>/dev/null'
alias metasploit='ls ~/installed-tools/metasploit 2>/dev/null'
alias nethunter='ls ~/installed-tools/kali-nethunter 2>/dev/null'
alias termux-setup='ls ~/installed-tools/termux-setup-repo 2>/dev/null'
EOF

echo -e "  ${GREEN}✓ 8 new aliases added${RESET}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✅ ALL $COUNT TOOLS INSTALLED!                  ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
echo "Installed collections:"
du -sh "$INSTALLED"/*/ 2>/dev/null | sort -rh
echo ""
echo "Total: $(du -sh "$INSTALLED" | cut -f1)"
echo ""
echo "Reload: source ~/.bashrc"
echo ""
