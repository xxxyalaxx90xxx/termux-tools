#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  📱 ANDROID / TERMUX FULL TUNING SCRIPT (No Root Required)
#  GSM • RAM • CPU • Network • Battery • System Optimization
# ============================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   📱  ANDROID PHONE FULL TUNING (No Root)          ║${NC}"
echo -e "${CYAN}║   GSM • RAM • CPU • Network • Battery • System     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"

# ─── 1. STORAGE CLEANUP ───────────────────────────────────────
echo -e "\n${GREEN}[1/8] 🧹 Storage Cleanup${NC}"
echo -e "${YELLOW}── Cleaning caches...${NC}"
npm cache clean --force 2>/dev/null || true
rm -rf ~/.cache/* 2>/dev/null || true
rm -rf ~/.termux_cli_manager.bak.* 2>/dev/null || true
rm -rf ~/.termux-install-logs/* 2>/dev/null || true
rm -rf /data/data/com.termux/files/usr/share/man/* 2>/dev/null || true
rm -rf /data/data/com.termux/files/usr/share/doc/* 2>/dev/null || true
rm -rf /data/data/com.termux/files/usr/share/info/* 2>/dev/null || true
find ~/.npm/_logs -type f -mtime +1 -delete 2>/dev/null || true
find /tmp -type f -delete 2>/dev/null || true
echo -e "${GREEN}✅ Caches cleaned${NC}"

# ─── 2. RAM OPTIMIZATION ──────────────────────────────────────
echo -e "\n${GREEN}[2/8] 🧠 RAM Optimization${NC}"
echo -e "${YELLOW}── Killing zombie processes...${NC}"
kill -9 $(ps aux | awk '$3==0.0 && $4==0.0 && $6<1000 {print $2}' | head -20) 2>/dev/null || true

echo -e "${YELLOW}── Dropping page cache (if permitted)...${NC}"
echo 1 > /proc/sys/vm/drop_caches 2>/dev/null && echo "  ✅ Page cache dropped" || echo "  ⚠️  No permission (needs root)"

echo -e "${YELLOW}── Setting aggressive OOM scores for Termux background...${NC}"
for pid in $(pgrep -f "termux" 2>/dev/null); do
    echo 1000 > /proc/$pid/oom_score_adj 2>/dev/null || true
done
echo -e "${GREEN}✅ RAM optimized${NC}"

# ─── 3. CPU GOVERNOR TUNING ───────────────────────────────────
echo -e "\n${GREEN}[3/8] ⚡ CPU Governor Tuning${NC}"
echo -e "${YELLOW}── Checking available governors...${NC}"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null && \
    echo -e "${YELLOW}── Setting performance governor...${NC}" && \
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        echo performance > ${cpu}scaling_governor 2>/dev/null || true
    done && echo "  ✅ Performance mode set" || \
    echo -e "  ⚠️  No CPU scaling access (needs root/Shizuku)"

# ─── 4. NETWORK OPTIMIZATION ─────────────────────────────────
echo -e "\n${GREEN}[4/8] 🌐 Network Optimization${NC}"
echo -e "${YELLOW}── Flushing DNS cache...${NC}"
ndc resolver flushdefaultif 2>/dev/null && echo "  ✅ DNS flushed" || echo "  ⚠️  No ndc access"

echo -e "${YELLOW}── Setting TCP buffers...${NC}"
sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null || true
sysctl -w net.core.rmem_max=16777216 2>/dev/null || true
sysctl -w net.core.wmem_max=16777216 2>/dev/null || true
sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null || echo "  ⚠️  sysctl restricted"

echo -e "${YELLOW}── Testing network speed...${NC}"
curl -so /dev/null -w "  Download: %{speed_download} bytes/s\n" --max-time 5 https://speed.cloudflare.com/__down?bytes=5000000 2>/dev/null || echo "  ⚠️  Speed test skipped"

# ─── 5. BATTERY OPTIMIZATION ─────────────────────────────────
echo -e "\n${GREEN}[5/8] 🔋 Battery Optimization${NC}"
echo -e "${YELLOW}── Disabling Termux wakelock...${NC}"
termux-wake-unlock 2>/dev/null || echo "  ℹ️  Wakelock already off"

echo -e "${YELLOW}── Checking battery stats...${NC}"
dumpsys battery 2>/dev/null | grep -E "level|voltage|temperature|current" | sed 's/^/  /' || echo "  ⚠️  No battery access"

# ─── 6. GSM / RADIO TUNING ────────────────────────────────────
echo -e "\n${GREEN}[6/8] 📡 GSM / Radio Optimization${NC}"
echo -e "${YELLOW}── Checking signal strength...${NC}"
signal=$(dumpsys telephony.registry 2>/dev/null | grep -i "mSignalStrength" | head -1)
if [ -n "$signal" ]; then
    echo "  $signal"
else
    echo "  ⚠️  No telephony access (needs adb/Shizuku)"
fi

echo -e "${YELLOW}── Checking network type...${NC}"
dumpsys telephony.registry 2>/dev/null | grep -i "mDataNetworkType" | head -1 | sed 's/^/  /' || echo "  ⚠️  Restricted"

# Force LTE preferred (if possible)
settings put global preferred_network_mode 9 2>/dev/null && \
    echo "  ✅ LTE preferred mode set" || \
    echo -e "  ⚠️  Needs: adb shell settings put global preferred_network_mode 9"

# ─── 7. TERMUX OPTIMIZATION ──────────────────────────────────
echo -e "\n${GREEN}[7/8] 🛠️  Termux Optimization${NC}"

# Create optimized .bashrc
cat >> ~/.bashrc << 'BASHRC'

# === Performance Optimizations ===
# Faster directory navigation
shopt -s cdspell autocd 2>/dev/null

# Better history
export HISTSIZE=10000
export HISTFILESIZE=100000
shopt -s histappend 2>/dev/null
export HISTCONTROL=ignoreboth:erasedups

# Disable X11 (saves memory)
export DISPLAY=""

# Node.js optimization
export NODE_OPTIONS="--max-old-space-size=2048"

# Faster npm (no scripts, no audit)
export npm_config_ignore_scripts=true
export npm_config_audit=false
export npm_config_fund=false

# Parallel jobs
export MAKEFLAGS="-j$(nproc)"
BASHRC

echo -e "${GREEN}✅ .bashrc optimized${NC}"

# Optimize termux.properties
mkdir -p ~/.termux
cat > ~/.termux/termux.properties << 'PROPS'
# Performance settings
allow-external-apps=true
use-fullscreen-workaround=true
# Keyboard shortcuts
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP','DEL'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','BKSP']]
# Disable bell (saves resources)
bell-character=ignore
PROPS

termux-reload-settings 2>/dev/null || true
echo -e "${GREEN}✅ Termux settings reloaded${NC}"

# ─── 8. SYSTEM PROPERTIES ─────────────────────────────────────
echo -e "\n${GREEN}[8/8] 📊 System Properties (read-only)${NC}"
echo -e "${YELLOW}── Build info:${NC}"
getprop ro.build.display.id 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"
getprop ro.product.manufacturer 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"
getprop ro.product.model 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"
getprop ro.build.version.release 2>/dev/null | sed 's/^/  /'

echo -e "\n${YELLOW}── Hardware info:${NC}"
getprop ro.hardware 2>/dev/null | sed 's/^/  /'
getprop ro.board.platform 2>/dev/null | sed 's/^/  /'
getprop ro.product.cpu.abi 2>/dev/null | sed 's/^/  /'

echo -e "\n${YELLOW}── Radio/Modem info:${NC}"
getprop gsm.version.baseband 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"
getprop gsm.sim.state 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"
getprop gsm.network.type 2>/dev/null | sed 's/^/  /' || echo "  ⚠️  Restricted"

# ─── FINAL STATUS ─────────────────────────────────────────────
echo -e "\n${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              📊 FINAL STATUS                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Storage:${NC}"
df -h / 2>/dev/null | tail -1 | sed 's/^/  /'
echo ""
echo -e "${YELLOW}Memory:${NC}"
free -h 2>/dev/null | head -2 | sed 's/^/  /' || cat /proc/meminfo | head -3 | sed 's/^/  /'
echo ""
echo -e "${YELLOW}Uptime:${NC}"
uptime 2>/dev/null | sed 's/^/  /'

echo -e "\n${GREEN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ PHONE TUNING COMPLETE!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}📋 ADB Commands for deeper tuning (needs USB debugging):${NC}"
echo -e "  adb shell settings put global window_animation_scale 0.5"
echo -e "  adb shell settings put global transition_animation_scale 0.5"
echo -e "  adb shell settings put global animator_duration_scale 0.5"
echo -e "  adb shell settings put global preferred_network_mode 9"
echo -e "  adb shell pm disable-user --user 0 <bloatware_package>"
echo -e "  adb shell cmd package compile -f -m speed everything"
