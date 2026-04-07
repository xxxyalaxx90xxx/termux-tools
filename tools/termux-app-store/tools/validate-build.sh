#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/colors.sh"
if [[ -f "$COLORS_FILE" ]]; then
  source "$COLORS_FILE"
else
  BOLD_RED=""
  BOLD_GREEN=""
  BOLD_YELLOW=""
  BOLD_CYAN=""
  CYAN=""
  RESET=""
fi

FILE="${1:-}"
if [[ -z "$FILE" ]]; then
    echo -e "${BOLD_YELLOW}Usage:${RESET} validate-build.sh <path/to/build.sh>"
    exit 2
fi

if [[ ! -f "$FILE" ]]; then
    echo -e "${BOLD_RED}❌ ERROR:${RESET} File not found: $FILE"
    exit 2
fi

PACKAGE_NAME="$(basename "$(dirname "$FILE")")"
echo -e "${BOLD_CYAN}🔎 Validating build.sh → 📦$PACKAGE_NAME${RESET}"
echo -e "${CYAN}=================================================${RESET}"

FAIL=0

check_var() {
    local var="$1"
    if ! grep -Eq "^${var}=" "$FILE"; then
        echo -e "${BOLD_RED}❌ FAIL :${RESET} $var is missing"
        FAIL=1
        return
    fi
    local val
    val=$(grep -E "^${var}=" "$FILE" | head -1 | sed "s/^${var}=//;s/^[\"']//;s/[\"']$//")
    if [[ -z "$val" ]]; then
        echo -e "${BOLD_RED}❌ FAIL :${RESET} $var is empty"
        FAIL=1
    else
        echo -e "${BOLD_GREEN}✅ OK   :${RESET} $var"
    fi
}

check_var "TERMUX_PKG_HOMEPAGE"
check_var "TERMUX_PKG_DESCRIPTION"
check_var "TERMUX_PKG_LICENSE"
check_var "TERMUX_PKG_MAINTAINER"
check_var "TERMUX_PKG_VERSION"
check_var "TERMUX_PKG_SRCURL"
check_var "TERMUX_PKG_SHA256"

if grep -q "dpkg -i" "$FILE"; then
    echo -e "${BOLD_YELLOW}⚠️  WARN :${RESET} build.sh contains 'dpkg -i' (not allowed in Termux build)"
fi

if grep -q "sudo " "$FILE"; then
    echo -e "${BOLD_RED}❌ FAIL :${RESET} sudo usage detected"
    FAIL=1
fi

if grep -q "apt install" "$FILE"; then
    echo -e "${BOLD_YELLOW}⚠️  WARN :${RESET} apt install found (use pkg install instead)"
fi


_load_pkg_vars() {
    set +u
    source "$FILE"
    set -u

    local resolved
    resolved="$(eval echo "$TERMUX_PKG_SRCURL")"
    echo "$resolved"
}

SRCURL="$(_load_pkg_vars)"
EXPECTED_SHA="$(set +u; source "$FILE" 2>/dev/null; set -u; echo "${TERMUX_PKG_SHA256:-}")"

if [[ -z "$EXPECTED_SHA" ]]; then
    echo -e "   ${BOLD_YELLOW}\nHint:\n Fill TERMUX_PKG_ SHA256 with the SHA256 from the file in TERMUX _PKG_SRCURL${RESET}"
    FAIL=1
elif [[ -n "$SRCURL" ]]; then
    echo
    echo -e "${BOLD_CYAN}🔎 Verifying SHA256 of source package 📦 $PACKAGE_NAME...${RESET}"
    echo -e "   ${CYAN}URL: $SRCURL${RESET}"

    TMPFILE=$(mktemp)

    HTTP_CODE=$(curl -fsSL \
        --max-time 60 \
        --connect-timeout 15 \
        --retry 2 \
        --retry-delay 2 \
        -w "%{http_code}" \
        -o "$TMPFILE" \
        "$SRCURL" 2>/dev/null) || {
            HTTP_CODE="$?"
            echo -e "${BOLD_RED}❌ Failed to download source${RESET}"
            echo -e "   URL      : $SRCURL"
            echo -e "   Exit code: $HTTP_CODE"
            echo -e "   ${BOLD_YELLOW}\nHint:\n Make sure the URL in TERMUX_PKG_SRCURL is valid and the file/url is publicly accessible.${RESET}"
            rm -f "$TMPFILE"
            FAIL=1
            HTTP_CODE=""
    }

    if [[ -n "$HTTP_CODE" && "$HTTP_CODE" != "200" && "$HTTP_CODE" != "0" ]]; then
        echo -e "${BOLD_RED}❌ HTTP $HTTP_CODE from server${RESET}"
        echo -e "   URL: $SRCURL"
        rm -f "$TMPFILE"
        FAIL=1
    elif [[ -f "$TMPFILE" ]]; then
        FILE_SIZE=$(wc -c < "$TMPFILE")
        if [[ "$FILE_SIZE" -eq 0 ]]; then
            echo -e "${BOLD_RED}❌ Downloaded file is empty (0 bytes)${RESET}"
            echo -e "   ${BOLD_YELLOW}\nHint:\n The URL may redirect to an error page or a non-existent file${RESET}"
            rm -f "$TMPFILE"
            FAIL=1
        else
            ACTUAL_SHA=$(sha256sum "$TMPFILE" | awk '{print $1}')
            rm -f "$TMPFILE"

            if [[ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]]; then
                echo -e "${BOLD_RED}❌ SHA256 mismatch!${RESET}"
                echo -e "   Expected: ${BOLD_YELLOW}$EXPECTED_SHA${RESET}"
                echo -e "   Got     : ${BOLD_YELLOW}$ACTUAL_SHA${RESET}"
                echo -e "   Size    : ${FILE_SIZE} bytes"
                echo -e "   ${BOLD_YELLOW}\nHint:\n Update TERMUX_PKG_SHA256 in build.sh with the 'Got' value above${RESET}"
                FAIL=1
            else
                echo -e "${BOLD_GREEN}✅ SHA256 verified${RESET} (${FILE_SIZE} bytes)"
            fi
        fi
    fi
fi

echo -e "${CYAN}-------------------------------------------------${RESET}"
if [[ "$FAIL" -eq 1 ]]; then
    echo -e "${BOLD_RED}❌ VALIDATION FAILED${RESET}"
    exit 1
else
    echo -e "${BOLD_GREEN}✅ VALIDATION PASSED${RESET}"
    exit 0
fi
