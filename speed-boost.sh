#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  🚀 SPEED BOOST - Kill Bloat, Free RAM, Optimize Everything
# ============================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 SPEED BOOST ACTIVATED${NC}"
echo ""

# 1. Kill background apps (Android activity manager)
echo -e "${YELLOW}[1] Killing background processes...${NC}"
am kill-all 2>/dev/null && echo "  ✅ Background apps killed" || echo "  ⚠️ am kill-all denied"

# 2. Force stop bloatware packages
echo -e "${YELLOW}[2] Checking bloatware...${NC}"
BLOAT=(
    "com.google.android.videos"
    "com.google.android.music"
    "com.google.android.apps.tachyon"
    "com.facebook.system"
    "com.facebook.appmanager"
    "com.facebook.services"
    "com.android.chrome"
)
for pkg in "${BLOAT[@]}"; do
    am force-stop "$pkg" 2>/dev/null && echo "  ✅ Stopped: $pkg" || true
done
echo "  Done."

# 3. Trim memory
echo -e "${YELLOW}[3] Trimming memory caches...${NC}"
su -c "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null && echo "  ✅ Caches dropped" || echo "  ⚠️ Needs root"

# 4. Force GC on all apps
echo -e "${YELLOW}[4] Triggering GC on running apps...${NC}"
cmd package bg-dexopt-job 2>/dev/null &
echo "  ℹ️  Background dexopt started (runs in background)"

# 5. Display final status
echo ""
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo -e "${GREEN}  🚀 SPEED BOOST COMPLETE!${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo ""
free -h 2>/dev/null | head -2 || cat /proc/meminfo | head -3
