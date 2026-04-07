#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Bratucha's Termux Startpage v1.0
# ═══════════════════════════════════════════════════════

clear

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; BOLD='\033[1m'; RESET='\033[0m'

# Gather info
MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
ANDROID=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP 'inet \K[\d.]+' || echo "N/A")
UPTIME=$(cat /proc/uptime 2>/dev/null | cut -d' ' -f1 | cut -d'.' -f1 || echo "?")
if [ -n "$UPTIME" ] && [ "$UPTIME" -gt 0 ] 2>/dev/null; then
  UPTIME_FMT="$((UPTIME/3600))h $(( (UPTIME%3600)/60 ))m"
else
  UPTIME_FMT="N/A"
fi
HOME_SIZE=$(du -sh ~ 2>/dev/null | cut -f1)
RAM_USED=$(free -h 2>/dev/null | grep Mem | awk '{print $3}')
RAM_AVAIL=$(free -h 2>/dev/null | grep Mem | awk '{print $7}')
BATT=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "N/A")

# Banner
echo -e "${CYAN}"
echo '  ╔══════════════════════════════════════════════════════════╗'
echo '  ║           🔥  BRATUCHA TERMUX STARTPAGE  🔥             ║'
echo '  ╚══════════════════════════════════════════════════════════╝'
echo -e "${RESET}"

# System Info
echo -e "  ${BOLD}📱 System${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}Device:${RESET}   ${BRAND} ${MODEL}"
echo -e "  ${WHITE}Android:${RESET}  ${ANDROID}"
echo -e "  ${WHITE}IP:${RESET}       ${IP}"
echo -e "  ${WHITE}Uptime:${RESET}   ${UPTIME_FMT}"
[ "$BATT" != "N/A" ] && echo -e "  ${WHITE}Akku:${RESET}     ${BATT}%"
echo ""

# Resources
echo -e "  ${BOLD}💾 Resources${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${WHITE}RAM:${RESET}     ${RAM_USED} used | ${RAM_AVAIL} available"
echo -e "  ${WHITE}Home:${RESET}    ${HOME_SIZE}"
echo ""

# Quick Commands
echo -e "  ${BOLD}⚡ Quick Commands${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${GREEN}dashboard${RESET}     System dashboard"
echo -e "  ${GREEN}sysinfo${RESET}       RAM + disk + kernel"
echo -e "  ${GREEN}memstat${RESET}       Memory stats"
echo -e "  ${GREEN}memwatch${RESET}      Live monitor"
echo -e "  ${GREEN}tuneup${RESET}        Install + optimize"
echo -e "  ${GREEN}killbg${RESET}        Kill bg processes"
echo -e "  ${GREEN}restart${RESET}       Reload shell"
echo -e "  ${GREEN}mp${RESET}            Max power mode"
echo ""

# AI Tools
echo -e "  ${BOLD}🤖 AI Tools${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${MAGENTA}qwen${RESET}          Qwen Code $(qwen --version 2>/dev/null | head -1)"
echo -e "  ${MAGENTA}gemini${RESET}        Gemini CLI"
echo -e "  ${MAGENTA}cont${RESET}          Continue.dev CLI"
echo -e "  ${MAGENTA}ai-dash${RESET}       AI Dashboard"
echo -e "  ${MAGENTA}ai-hub${RESET}        AI Hub"
echo ""

# Scripts
echo -e "  ${BOLD}📜 Scripts${RESET}"
echo -e "  ─────────────────────────────────────────────────────"
echo -e "  ${YELLOW}writer${RESET}       Writer Tool v4.0 (120+ commands)"
echo -e "  ${YELLOW}speed-boost${RESET}   Network optimization"
echo -e "  ${YELLOW}phone-tune${RESET}    Phone tuning"
echo -e "  ${YELLOW}matrix-rain${RESET}   Matrix animation"
echo -e "  ${YELLOW}download-models${RESET} Download AI models"
echo -e "  ${YELLOW}tcm${RESET}           Termux CLI Manager"
echo ""

# .scripts directory
if [ -d "$HOME/.scripts" ]; then
  SCRIPT_COUNT=$(ls "$HOME/.scripts" 2>/dev/null | wc -l)
  if [ "$SCRIPT_COUNT" -gt 0 ]; then
    echo -e "  ${BOLD}📂 .scripts (${SCRIPT_COUNT})${RESET}"
    echo -e "  ─────────────────────────────────────────────────────"
    ls "$HOME/.scripts" 2>/dev/null | while read f; do
      name="${f%.*}"
      echo -e "  ${YELLOW}${name}${RESET}"
    done
    echo ""
  fi
fi

# Warning
DISK_USE=$(df / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USE" = "100" ]; then
  echo -e "  ${RED}⚠️  WARNUNG: System-Partition ist VOLL!${RESET}"
  echo -e "  ${RED}   → cache aufräumen: rm -rf ~/.cache/*${RESET}"
  echo ""
fi

echo -e "  ${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "  ${WHITE}Have fun! 🚀${RESET}"
echo ""
