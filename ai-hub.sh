#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  🤖 AI HUB - Dein persönlicher AI Command Center
#  Alle AI-Tools an einem Ort!
# ============================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          🤖  AI COMMAND CENTER  🤖                 ║${NC}"
echo -e "${CYAN}║   Qwen • Gemini • Claude • Continue • NexusAI      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Show AI tools status
echo -e "${YELLOW}📊 Verfügbare AI-Tools:${NC}"
echo -e "─────────────────────────────────────"

# Qwen
qwen_version=$(qwen --version 2>/dev/null || echo "❌ Nicht installiert")
echo -e "  🟣 ${MAGENTA}Qwen Code${NC}         → $qwen_version"

# Gemini
gemini_version=$(gemini --version 2>/dev/null || echo "❌ Nicht installiert")
echo -e "  🔵 ${CYAN}Gemini CLI${NC}       → $gemini_version"

# Claude
claude_version=$(claude --version 2>/dev/null || echo "❌ Nicht installiert")
echo -e "  🟠 ${YELLOW}Claude Code${NC}      → $claude_version"

# Continue
continue_version=$(continue --version 2>/dev/null || echo "❌ Nicht installiert")
echo -e "  🟢 ${GREEN}Continue${NC}          → $continue_version"

# NexusAI
nexuscli_version=$(nexuscli --version 2>/dev/null || echo "❌ Nicht installiert")
echo -e "  ⚪ ${CYAN}NexusAI${NC}           → $nexuscli_version"

# Codey-v2
if [[ -f "$HOME/Codey-v2/codey2" ]]; then
    echo -e "  🤖 ${GREEN}Codey-v2${NC}          → bereit"
else
    echo -e "  🤖 ${GREEN}Codey-v2${NC}          → ❌ Nicht gefunden"
fi

# SMS AI Agent
if [[ -f "$HOME/sms-ai-agent/main.py" ]]; then
    echo -e "  💬 ${YELLOW}SMS AI Agent${NC}      → bereit"
else
    echo -e "  💬 ${YELLOW}SMS AI Agent${NC}      → ❌ Nicht gefunden"
fi

echo -e "─────────────────────────────────────"
echo ""

# Menu
echo -e "${GREEN}[1] 🟣 Qwen Code starten${NC}"
echo -e "${GREEN}[2] 🔵 Gemini CLI starten${NC}"
echo -e "${GREEN}[3] 🟠 Claude Code starten${NC}"
echo -e "${GREEN}[4] 🟢 Continue Dev starten${NC}"
echo -e "${GREEN}[5] ⚪ NexusAI starten${NC}"
echo -e "${GREEN}[6] 🤖 Codey-v2 starten${NC}"
echo -e "${GREEN}[7] 💬 SMS AI Agent (TUI)${NC}"
echo -e "${GREEN}[8] 🔥 Alle AI-Tools updaten${NC}"
echo -e "${GREEN}[9] 🧠 AI System Info${NC}"
echo -e "${GREEN}[0] ❌ Beenden${NC}"
echo ""

read -p "👉 Wahl: " choice

case $choice in
    1)
        echo -e "${MAGENTA}🚀 Starte Qwen Code...${NC}"
        qwen
        ;;
    2)
        echo -e "${CYAN}🚀 Starte Gemini CLI...${NC}"
        gemini
        ;;
    3)
        echo -e "${YELLOW}🚀 Starte Claude Code...${NC}"
        claude
        ;;
    4)
        echo -e "${GREEN}🚀 Starte Continue Dev...${NC}"
        continue
        ;;
    5)
        echo -e "${CYAN}🚀 Starte NexusAI...${NC}"
        nexus
        ;;
    6)
        echo -e "${GREEN}🚀 Starte Codey-v2...${NC}"
        python3 "$HOME/Codey-v2/main.py"
        ;;
    7)
        echo -e "${YELLOW}🚀 Starte SMS AI Agent...${NC}"
        cd "$HOME/sms-ai-agent" && bash run_tui.sh
        ;;
    8)
        echo -e "${YELLOW}🔄 Starte umfassendes System & AI Update...${NC}"
        pkg update -y && pkg upgrade -y
        npm update -g 2>&1 | grep -v "npm warn"
        pip install --upgrade pip
        echo -e "${YELLOW}🔄 Aktualisiere Repositories...${NC}"
        [ -d "$HOME/AllHackingTools/Danxy" ] && (cd "$HOME/AllHackingTools/Danxy" && git pull)
        [ -d "$HOME/Codey-v2" ] && (cd "$HOME/Codey-v2" && git pull)
        [ -d "$HOME/sms-ai-agent" ] && (cd "$HOME/sms-ai-agent" && git pull)
        [ -f "$HOME/termux_cli_manager.py" ] && python3 "$HOME/termux_cli_manager.py" --check-updates
        echo -e "${GREEN}✅ Alle Komponenten aktualisiert!${NC}"
        sleep 2
        exec "$0"
        ;;
    9)
        echo ""
        echo -e "${CYAN}══════════════════════════════════════${NC}"
        echo -e "${CYAN}  🧠 AI SYSTEM INFO${NC}"
        echo -e "${CYAN}══════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Gerät:${NC}"
        echo "  Model: $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
        echo "  Android: $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')"
        echo "  RAM: $(free -h 2>/dev/null | head -2 | tail -1 | awk '{print $2}')"
        echo "  Verfügbar: $(free -h 2>/dev/null | head -2 | tail -1 | awk '{print $7}')"
        echo ""
        echo -e "${YELLOW}Node.js:${NC}"
        node -v 2>/dev/null | sed 's/^/  /'
        npm -v 2>/dev/null | sed 's/^/  /'
        echo ""
        echo -e "${YELLOW}Installierte AI-Pakete:${NC}"
        npm list -g --depth=0 2>/dev/null | grep -E '@|claude|gemini|qwen|continue|nexus' | sed 's/^/  /'
        echo ""
        echo -e "${CYAN}══════════════════════════════════════${NC}"
        sleep 3
        exec "$0"
        ;;
    0)
        echo -e "${RED}👋 AI Hub geschlossen!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Ungültige Wahl!${NC}"
        sleep 1
        exec "$0"
        ;;
esac
