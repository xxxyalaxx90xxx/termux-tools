#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Bratucha's Termux Startpage v2.0 - ALL TOOLS
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

# Banner
echo -e "${CYAN}"
echo '  ╔══════════════════════════════════════════════════════╗'
echo '  ║        🔥  BRATUCHA TERMUX STARTPAGE  🔥             ║'
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
echo -e "  ${MAGENTA}qwen${RESET}         Qwen Code ${QWEN_VER}"
echo -e "  ${MAGENTA}gemini${RESET}       Gemini CLI"
echo -e "  ${MAGENTA}cont${RESET}         Continue.dev CLI"
echo -e "  ${MAGENTA}ai-dash${RESET}      AI Dashboard"
echo -e "  ${MAGENTA}ai-hub${RESET}       AI Hub"
echo ""

# Main Tools
echo -e "  ${BOLD}⚡ Main Tools${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${GREEN}launcher${RESET}     Ultimate Tool Launcher (29 Tools)"
echo -e "  ${GREEN}dashboard${RESET}    Web Dashboard (Port 8080)"
echo -e "  ${GREEN}writer${RESET}       Writer Tool v4.0 (120+ commands)"
echo -e "  ${GREEN}system-tune${RESET}  System Tuning"
echo -e "  ${GREEN}tcm${RESET}          CLI Manager v9.0"
echo ""

# Tool Collections
echo -e "  ${BOLD}📦 GitHub Collections (${TOOL_COUNT})${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${YELLOW}lazymux${RESET}      800+ Tools Installer"
echo -e "  ${YELLOW}wolkansec${RESET}    354 Security Tools"
echo -e "  ${YELLOW}m4t01${RESET}        380+ Tools Launcher"
echo -e "  ${YELLOW}slstore${RESET}      Tool Store TUI"
echo -e "  ${YELLOW}tas${RESET}          Termux App Store (TUI)"
echo -e "  ${YELLOW}termux-style${RESET} Terminal Styling"
echo -e "  ${YELLOW}bash-snippets${RESET} CLI Utilities"
echo -e "  ${YELLOW}awesome-bash${RESET}  Bash Resources"
echo -e "  ${YELLOW}shizuku${RESET}      Shizuku Integration"
echo -e "  ${YELLOW}pdf-tools${RESET}    PDF Handling"
echo ""

# Scripts
echo -e "  ${BOLD}📜 Scripts${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${CYAN}speed-boost${RESET}   Network optimization"
echo -e "  ${CYAN}phone-tune${RESET}    Phone tuning"
echo -e "  ${CYAN}matrix-rain${RESET}   Matrix animation"
echo -e "  ${CYAN}download-models${RESET} Download AI models"
echo ""

# Quick Commands
echo -e "  ${BOLD}🔧 Quick Commands${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}sysinfo${RESET}      RAM + disk + kernel"
echo -e "  ${WHITE}memstat${RESET}      Memory stats"
echo -e "  ${WHITE}mp${RESET}           Max power mode"
echo -e "  ${WHITE}killbg${RESET}       Kill bg processes"
echo -e "  ${WHITE}restart${RESET}      Reload shell"
echo ""

# Warning
DISK_USE=$(df / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USE" = "100" ]; then
  echo -e "  ${RED}⚠️  WARNUNG: System-Partition ist VOLL!${RESET}"
  echo -e "  ${RED}     → rm -rf ~/.cache/*${RESET}"
  echo ""
fi

echo -e "  ${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "  ${WHITE}Have fun! 🚀${RESET}"
echo ""
