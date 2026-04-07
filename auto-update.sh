#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Bratucha's Auto-Update System v1.0
#  Updates all tools, repos, and packages
# ═══════════════════════════════════════════════════════

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${CYAN}"
echo '╔══════════════════════════════════════════════════╗'
echo '║   🔄  AUTO-UPDATE SYSTEM v1.0                    ║'
echo '╚══════════════════════════════════════════════════╝'
echo -e "${RESET}"

echo -e "${BOLD}[1/5] Package Update${RESET}"
pkg update -y -q 2>/dev/null | tail -2
echo -e "  ${GREEN}✓ Packages updated${RESET}"

echo -e "${BOLD}[2/5] GitHub Repo Pull${RESET}"
cd ~/github-repo 2>/dev/null && git pull --rebase 2>/dev/null | tail -2
echo -e "  ${GREEN}✓ Repo updated${RESET}"

echo -e "${BOLD}[3/5] Tool Collections Update${RESET}"
for dir in ~/github-tools/*/; do
    if [ -d "$dir/.git" ]; then
        cd "$dir" && git pull --rebase 2>/dev/null | tail -1
    fi
done
echo -e "  ${GREEN}✓ Collections updated${RESET}"

echo -e "${BOLD}[4/5] Python Tools Sync${RESET}"
cp ~/github-repo/.writer.sh ~/.writer.sh 2>/dev/null
cp ~/github-repo/.startpage.sh ~/.startpage.sh 2>/dev/null
cp ~/github-repo/launcher.sh ~/launcher.sh 2>/dev/null
cp ~/github-repo/dashboard.py ~/dashboard.py 2>/dev/null
cp ~/github-repo/system-tune.sh ~/system-tune.sh 2>/dev/null
chmod +x ~/.writer.sh ~/.startpage.sh ~/launcher.sh ~/system-tune.sh 2>/dev/null
echo -e "  ${GREEN}✓ Tools synced${RESET}"

echo -e "${BOLD}[5/5] Cache Cleanup${RESET}"
rm -rf ~/.cache/pip ~/.cache/http 2>/dev/null
find ~ -name "__pycache__" -exec rm -rf {} + 2>/dev/null
echo -e "  ${GREEN}✓ Cache cleaned${RESET}"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✅ AUTO-UPDATE COMPLETE                        ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
