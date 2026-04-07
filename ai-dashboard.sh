#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  📊 AI DASHBOARD - Dein AI System Status
# ============================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${WHITE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║         📊  AI DASHBOARD  📊                       ║${NC}"
echo -e "${WHITE}║   All AI Tools Status & System Info                ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ─── AI TOOLS STATUS ─────────────────────────────────────────
echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│  🤖 AI TOOLS STATUS                                │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"

tools=(
    "qwen|🟣 Qwen Code"
    "gemini|🔵 Gemini CLI"
    "claude|🟠 Claude Code"
    "continue|🟢 Continue Dev"
    "nexuscli|⚪ NexusAI"
    "Codey-v2/main.py|🤖 Codey-v2"
    "sms-ai-agent/main.py|💬 SMS AI Agent"
    "ai-hub.sh|🎮 AI Hub"
    "ai-bot.py|💬 AI Chatbot"
)

for entry in "${tools[@]}"; do
    IFS='|' read -r cmd name <<< "$entry"
    if command -v "$cmd" &>/dev/null || [[ -f "$HOME/$cmd" ]]; then
        version=$($cmd --version 2>/dev/null | head -1 || echo "ready")
        echo -e "  ✅ $name → ${GREEN}$version${NC}"
    else
        echo -e "  ❌ $name → ${RED}Nicht verfügbar${NC}"
    fi
done

echo ""

# ─── SYSTEM INFO ─────────────────────────────────────────────
echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│  📱 SYSTEM INFO                                    │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"

echo -e "  📱 Gerät:      ${GREEN}$(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)${NC}"
echo -e "  🤖 Android:    ${GREEN}$(getprop ro.build.version.release 2>/dev/null)${NC}"
echo -e "  🧠 RAM Total:  ${YELLOW}$(free -h 2>/dev/null | head -2 | tail -1 | awk '{print $2}')${NC}"
echo -e "  🧠 RAM Used:   ${YELLOW}$(free -h 2>/dev/null | head -2 | tail -1 | awk '{print $3}')${NC}"
echo -e "  🧠 RAM Free:   ${GREEN}$(free -h 2>/dev/null | head -2 | tail -1 | awk '{print $7}')${NC}"
echo -e "  💾 Storage:    $(df -h "$HOME" 2>/dev/null | tail -1 | awk '{print "Used: "$3" / "$2" ("$5")"}')"
echo -e "  ⚡ CPU:        ${GREEN}$(getprop ro.board.platform 2>/dev/null) ($(nproc) cores)${NC}"

echo ""

# ─── NODE/AI ENVIRONMENT ─────────────────────────────────────
echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│  🛠️  AI ENVIRONMENT                               │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"

echo -e "  📦 Node.js:    ${GREEN}$(node -v 2>/dev/null)${NC}"
echo -e "  📦 npm:        ${GREEN}$(npm -v 2>/dev/null)${NC}"
echo -e "  📦 Python:     ${GREEN}$(python --version 2>/dev/null || echo 'Not installed')${NC}"

echo ""
echo -e "  ${YELLOW}Globale AI-Pakete:${NC}"
npm list -g --depth=0 2>/dev/null | grep -E '@|ai|code' | while read line; do
    echo -e "    📦 $line"
done

echo ""

# ─── API KEYS CHECK ──────────────────────────────────────────
echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│  🔑 API KEYS STATUS                                │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"

if [ -n "$GROQ_API_KEY" ]; then
    echo -e "  🔑 GROQ_API_KEY:      ${GREEN}✅ Gesetzt${NC}"
else
    echo -e "  🔑 GROQ_API_KEY:      ${YELLOW}⚠️  Nicht gesetzt${NC}"
fi

if [ -n "$OPENROUTER_API_KEY" ]; then
    echo -e "  🔑 OPENROUTER_API_KEY: ${GREEN}✅ Gesetzt${NC}"
else
    echo -e "  🔑 OPENROUTER_API_KEY: ${YELLOW}⚠️  Nicht gesetzt${NC}"
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "  🔑 ANTHROPIC_API_KEY:  ${GREEN}✅ Gesetzt${NC}"
else
    echo -e "  🔑 ANTHROPIC_API_KEY:  ${YELLOW}⚠️  Nicht gesetzt${NC}"
fi

if [ -n "$OPENAI_API_KEY" ]; then
    echo -e "  🔑 OPENAI_API_KEY:     ${GREEN}✅ Gesetzt${NC}"
else
    echo -e "  🔑 OPENAI_API_KEY:     ${YELLOW}⚠️  Nicht gesetzt${NC}"
fi

echo ""

# ─── QUICK ACTIONS ───────────────────────────────────────────
echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│  🚀 QUICK ACTIONS                                  │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"

echo -e "  ${GREEN}[1]${NC} ./ai-hub.sh      → AI Command Center"
echo -e "  ${GREEN}[2]${NC} python ai-bot.py  → AI Chatbot"
echo -e "  ${GREEN}[3]${NC} qwen             → Qwen Code"
echo -e "  ${GREEN}[4]${NC} gemini           → Gemini CLI"
echo -e "  ${GREEN}[5]${NC} claude           → Claude Code"
echo -e "  ${GREEN}[6]${NC} ~/phone-tune.sh  → Phone Tuning"
echo -e "  ${GREEN}[7]${NC} ~/speed-boost.sh → Speed Boost"
echo ""

echo -e "${WHITE}══════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}  🤖 AI DASHBOARD COMPLETE!${NC}"
echo -e "${WHITE}══════════════════════════════════════════════════════${NC}"
