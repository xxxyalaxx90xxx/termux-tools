#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Bratucha's Termux Startpage v3.0 - ALL IN ONE
#  View + Install + Launch all tools
# ═══════════════════════════════════════════════════════

clear

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; BOLD='\033[1m'; RESET='\033[0m'

# System Info
MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
ANDROID=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
HOME_SIZE=$(du -sh ~ 2>/dev/null | cut -f1)
RAM_USED=$(free -h 2>/dev/null | grep Mem | awk '{print $3}')
RAM_AVAIL=$(free -h 2>/dev/null | grep Mem | awk '{print $7}')
BATT=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "N/A")
QWEN_VER=$(qwen --version 2>/dev/null | head -1 || echo "?")
TOOL_COUNT=$(ls ~/installed-tools/ 2>/dev/null | wc -l)
REPO_COMMITS=$(cd ~/github-repo 2>/dev/null && git rev-list --count HEAD 2>/dev/null || echo "?")
REPO_FILES=$(cd ~/github-repo 2>/dev/null && git ls-files 2>/dev/null | wc -l || echo "?")

# Banner
echo -e "${CYAN}"
echo '  ╔══════════════════════════════════════════════════════╗'
echo '  ║        🔥  BRATUCHA TERMUX STARTPAGE  🔥             ║'
echo '  ║              v3.0 - ALL IN ONE                       ║'
echo '  ╚══════════════════════════════════════════════════════╝'
echo -e "${RESET}"

# System Info
echo -e "  ${BOLD}📱 System${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}Device:${RESET}    ${BRAND} ${MODEL}"
echo -e "  ${WHITE}Android:${RESET}   ${ANDROID}"
echo -e "  ${WHITE}RAM:${RESET}       ${RAM_USED} used | ${RAM_AVAIL} available"
echo -e "  ${WHITE}Home:${RESET}      ${HOME_SIZE}"
[ "$BATT" != "N/A" ] && echo -e "  ${WHITE}Akku:${RESET}      ${BATT}%"
echo ""

# AI Tools
echo -e "  ${BOLD}🤖 AI Tools${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${MAGENTA}[1] qwen${RESET}         Qwen Code ${QWEN_VER}"
echo -e "  ${MAGENTA}[2] gemini${RESET}       Gemini CLI 0.36.0"
echo -e "  ${MAGENTA}[3] cont${RESET}         Continue.dev CLI"
echo -e "  ${MAGENTA}[4] ai-dash${RESET}      AI Dashboard"
echo -e "  ${MAGENTA}[5] ai-hub${RESET}       AI Hub"
echo ""

# Main Tools
echo -e "  ${BOLD}⚡ Main Tools${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${GREEN}[6]  launcher${RESET}     Ultimate Tool Launcher (29 Tools)"
echo -e "  ${GREEN}[7]  dashboard${RESET}    Web Dashboard (Port 8080)"
echo -e "  ${GREEN}[8]  writer / w${RESET}   Writer Tool v4.0 (120+ commands)"
echo -e "  ${GREEN}[9]  system-tune${RESET}  System Tuning"
echo -e "  ${GREEN}[10] tcm${RESET}          CLI Manager v9.0"
echo ""

# Tool Collections
echo -e "  ${BOLD}📦 GitHub Collections (${TOOL_COUNT})${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${YELLOW}[11] lazymux${RESET}      800+ Tools Installer"
echo -e "  ${YELLOW}[12] wolkansec${RESET}    354 Security Tools"
echo -e "  ${YELLOW}[13] m4t01${RESET}        380+ Tools Launcher"
echo -e "  ${YELLOW}[14] slstore${RESET}      Tool Store TUI"
echo -e "  ${YELLOW}[15] tas${RESET}          Termux App Store (TUI)"
echo -e "  ${YELLOW}[16] termux-style${RESET} Terminal Styling"
echo -e "  ${YELLOW}[17] bash-snippets${RESET} CLI Utilities"
echo -e "  ${YELLOW}[18] awesome-bash${RESET}  Bash Resources"
echo -e "  ${YELLOW}[19] shizuku${RESET}      Shizuku Integration"
echo -e "  ${YELLOW}[20] pdf-tools${RESET}    PDF Handling"
echo ""

# Scripts
echo -e "  ${BOLD}📜 Scripts${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${CYAN}[21] speed-boost${RESET}   Network optimization"
echo -e "  ${CYAN}[22] phone-tune${RESET}    Phone tuning"
echo -e "  ${CYAN}[23] matrix-rain${RESET}   Matrix animation"
echo -e "  ${CYAN}[24] download-models${RESET} Download AI models"
echo ""

# Maintenance
echo -e "  ${BOLD}🔧 Maintenance${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}[25] install-all${RESET}   Install all tools"
echo -e "  ${WHITE}[26] update${RESET}        Update packages"
echo -e "  ${WHITE}[27] clean${RESET}         Clean cache"
echo -e "  ${WHITE}[28] push${RESET}          Git push to GitHub"
echo -e "  ${WHITE}[29] test${RESET}          Run test suite"
echo ""

# GitHub Status
echo -e "  ${BOLD}📦 GitHub Status${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}Repo:${RESET}    github.com/xxxyalaxx90xxx/termux-tools"
echo -e "  ${WHITE}Commits:${RESET} ${REPO_COMMITS}  ${WHITE}Files:${RESET} ${REPO_FILES}"
echo -e "  ${WHITE}Size:${RESET}    $(du -sh ~/github-repo 2>/dev/null | cut -f1)"
echo ""

# Warning
DISK_USE=$(df / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USE" = "100" ]; then
  echo -e "  ${RED}⚠️  WARNUNG: System-Partition ist VOLL!${RESET}"
  echo -e "  ${RED}     → [27] clean ausfuehren${RESET}"
  echo ""
fi

echo -e "  ${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "  ${WHITE}Nummer waehlen oder 'q' fuer Exit${RESET}"
echo -e "  ${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -ne "${YELLOW}  > ${RESET}"
read choice

case $choice in
    1) qwen ;;
    2) gemini ;;
    3) cont ;;
    4) ai-dash ;;
    5) ai-hub ;;
    6) launcher ;;
    7) dashboard ;;
    8) writer ;;
    9) system-tune ;;
    10) tcm ;;
    11) lazymux ;;
    12) wolkansec ;;
    13) m4t01 ;;
    14) slstore ;;
    15) tas ;;
    16) termux-style ;;
    17) ls ~/installed-tools/bash-snippets/ ;;
    18) ls ~/installed-tools/awesome-bash/ ;;
    19) shizuku ;;
    20) ls ~/installed-tools/termux-pdf-tools/ ;;
    21) speed-boost ;;
    22) phone-tune ;;
    23) matrix-rain ;;
    24) download-models ;;
    25) bash ~/install-all-tools.sh ;;
    26) pkg update -y ;;
    27) rm -rf ~/.cache/pip ~/.cache/http && find ~ -name "__pycache__" -exec rm -rf {} + 2>/dev/null && echo -e "${GREEN}✅ Cleaned${RESET}" ;;
    28) cd ~/github-repo && git add -A && git status --short && read -p "Commit message: " msg && [ -n "$msg" ] && git commit -m "$msg" && git push ;;
    29) bash ~/test-all.sh ;;
    q|Q) echo -e "${GREEN}Bye! 👋${RESET}" ;;
    *) echo -e "${RED}Ungültig.${RESET}" ;;
esac
