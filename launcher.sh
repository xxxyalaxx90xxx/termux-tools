#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Bratucha's Ultimate Tool Launcher v1.0
#  Alle Tools in einem Menü
# ═══════════════════════════════════════════════════════

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

while true; do
    clear
    echo -e "${CYAN}"
    echo '╔══════════════════════════════════════════════════╗'
    echo '║     🔥  BRATUCHA TOOL LAUNCHER  🔥              ║'
    echo '║         Ultimate Termux Control Center           ║'
    echo '╚══════════════════════════════════════════════════╝'
    echo -e "${RESET}"

    # System Info
    RAM=$(free -h 2>/dev/null | grep Mem | awk '{printf "%s/%s", $3, $2}')
    HOME_SIZE=$(du -sh ~ 2>/dev/null | cut -f1)
    BATT=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "N/A")

    echo -e "  ${WHITE}RAM:${RESET} $RAM  ${WHITE}Home:${RESET} $HOME_SIZE  ${WHITE}Akku:${RESET} ${BATT}%"
    echo ""

    echo -e "  ${BOLD}📝 EDITORS & WRITING${RESET}"
    echo -e "    ${GREEN}[1]${RESET} Writer Tool v4.0          (120+ commands)"
    echo -e "    ${GREEN}[2]${RESET} Nano Editor"
    echo -e "    ${GREEN}[3]${RESET} Vim Editor"
    echo ""

    echo -e "  ${BOLD}🤖 AI TOOLS${RESET}"
    echo -e "    ${GREEN}[4]${RESET} Qwen Code"
    echo -e "    ${GREEN}[5]${RESET} Gemini CLI"
    echo -e "    ${GREEN}[6]${RESET} Continue.dev CLI"
    echo -e "    ${GREEN}[7]${RESET} AI Dashboard"
    echo -e "    ${GREEN}[8]${RESET} AI Hub"
    echo ""

    echo -e "  ${BOLD}📦 TOOL COLLECTIONS (GitHub)${RESET}"
    echo -e "    ${GREEN}[9]${RESET} Lazymux                   (800+ tools)"
    echo -e "    ${GREEN}[10]${RESET} Wolkansec                 (354 security tools)"
    echo -e "    ${GREEN}[11]${RESET} M4t01 Launcher            (380+ tools)"
    echo -e "    ${GREEN}[12]${RESET} SL Tool Store"
    echo -e "    ${GREEN}[13]${RESET} Termux App Store (TUI)"
    echo -e "    ${GREEN}[14]${RESET} Shizuku Tools"
    echo -e "    ${GREEN}[15]${RESET} PDF Tools"
    echo ""

    echo -e "  ${BOLD}⚡ SYSTEM TOOLS${RESET}"
    echo -e "    ${GREEN}[16]${RESET} System Tuning"
    echo -e "    ${GREEN}[17]${RESET} Speed Boost"
    echo -e "    ${GREEN}[18]${RESET} Phone Tune"
    echo -e "    ${GREEN}[19]${RESET} CLI Manager v9.0"
    echo -e "    ${GREEN}[20]${RESET} Startpage"
    echo ""

    echo -e "  ${BOLD}🎬 FUN & MISC${RESET}"
    echo -e "    ${GREEN}[21]${RESET} Matrix Rain"
    echo -e "    ${GREEN}[22]${RESET} System Dashboard"
    echo -e "    ${GREEN}[23]${RESET} Download Models"
    echo ""

    echo -e "  ${BOLD}🔧 MAINTENANCE${RESET}"
    echo -e "    ${GREEN}[24]${RESET} Update all packages"
    echo -e "    ${GREEN}[25]${RESET} Clean cache"
    echo -e "    ${GREEN}[26]${RESET} Git push to GitHub"
    echo -e "    ${GREEN}[0]${RESET} Exit"
    echo ""

    echo -ne "  ${YELLOW}Wähle [0-26]:${RESET} "
    read choice

    case $choice in
        1) bash ~/.writer.sh ;;
        2) nano ;;
        3) vim ;;
        4) qwen ;;
        5) gemini ;;
        6) cont ;;
        7) bash ~/ai-dashboard.sh ;;
        8) bash ~/ai-hub.sh ;;
        9) python3 ~/installed-tools/Lazymux/lazymux.py ;;
        10) python3 ~/installed-tools/wolkansec-tools/termux-tools.py ;;
        11) bash ~/installed-tools/m4t01-launcher/launcher.sh ;;
        12) python3 ~/installed-tools/sl-tool-store/store.py ;;
        13) ~/installed-tools/termux-app-store/tasctl ;;
        14) bash ~/installed-tools/shizuku-tools/setup.sh ;;
        15) ls ~/installed-tools/termux-pdf-tools/ ;;
        16) bash ~/system-tune.sh ;;
        17) bash ~/speed-boost.sh ;;
        18) bash ~/phone-tune.sh ;;
        19) python3 ~/termux_cli_manager.py ;;
        20) bash ~/.startpage.sh ;;
        21) python3 ~/matrix-rain.py ;;
        22) echo "=== RAM ===" && free -h && echo "=== DISK ===" && df -h / && echo "=== PROCESSES ===" && ps -e | head -10 ;;
        23) bash ~/download-models.sh ;;
        24) pkg update -y && echo "✅ Updated" ;;
        25) rm -rf ~/.cache/pip ~/.cache/http && find ~ -name "__pycache__" -exec rm -rf {} + 2>/dev/null && echo "✅ Cleaned" ;;
        26) cd ~/github-repo && git add -A && git status --short && read -p "Commit message: " msg && [ -n "$msg" ] && git commit -m "$msg" && git push ;;
        0) echo -e "${GREEN}Bye! 👋${RESET}"; exit 0 ;;
        *) echo -e "${RED}Ungültig.${RESET}" ;;
    esac

    echo ""
    echo -ne "${YELLOW}Enter für Menü...${RESET}"
    read
done
