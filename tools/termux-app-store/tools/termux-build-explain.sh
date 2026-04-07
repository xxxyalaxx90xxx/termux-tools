#!/usr/bin/env bash

set -eo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COLORS_FILE="$ROOT/tools/colors.sh"

if [[ -f "$COLORS_FILE" ]]; then
  source "$COLORS_FILE"
else
  BOLD_RED=""
  BOLD_GREEN=""
  BOLD_YELLOW=""
  CYAN=""
  RESET=""
fi

PKG="${1:-}"

if [[ -z "$PKG" ]]; then
  echo -e "${BOLD_RED}❌ Usage: termux-build explain <package>${RESET}"
  exit 1
fi

FILE="$ROOT/packages/$PKG/build.sh"

if [[ ! -f "$FILE" ]]; then
  echo -e "${BOLD_RED}❌ build.sh not found for package: $PKG${RESET}"
  exit 1
fi

set +u +e
source "$FILE" >/dev/null 2>&1 || true

echo -e "${CYAN}🧠 PR Risk Analysis: $PKG${RESET}"
echo -e "${CYAN}=================================================${RESET}"

RISK=0
WARN=0

check_field() {
  local name="$1"
  local value="$2"
  local suggestion="$3"

  if [[ -n "$value" ]]; then
    echo -e "${BOLD_GREEN}✔ ${name}:${RESET} $value"
  else
    echo -e "${BOLD_RED}❌ ${name}:${RESET} (empty)"
    echo -e "   ${BOLD_YELLOW}💡 Suggestion:${RESET} $suggestion"
    RISK=1
  fi
}

warn() {
  local msg="$1"
  echo -e "${BOLD_YELLOW}⚠️  WARN  : $msg${RESET}"
  WARN=1
}

info() {
  local msg="$1"
  echo -e "${CYAN}ℹ INFO  : $msg${RESET}"
}

check_field "TERMUX_PKG_SRCURL"  "${TERMUX_PKG_SRCURL:-}" \
  "Set a valid download URL (GitHub release, tar.gz, binary, etc)"

check_field "TERMUX_PKG_SHA256"  "${TERMUX_PKG_SHA256:-}" \
  "Generate with: sha256sum <file>"

check_field "TERMUX_PKG_VERSION" "${TERMUX_PKG_VERSION:-}" \
  "Example: TERMUX_PKG_VERSION=1.0.0"

check_field "TERMUX_PKG_LICENSE" "${TERMUX_PKG_LICENSE:-}" \
  "Example: MIT, Apache-2.0, GPL-3.0"

if [[ -n "${TERMUX_PKG_HOMEPAGE:-}" ]]; then
  echo -e "${BOLD_GREEN}✔ TERMUX_PKG_HOMEPAGE:${RESET} $TERMUX_PKG_HOMEPAGE"
else
  warn "No homepage set (recommended for PR & metadata quality)"
fi

if [[ -n "${TERMUX_PKG_DESCRIPTION:-}" ]]; then
  echo -e "${BOLD_GREEN}✔ TERMUX_PKG_DESCRIPTION:${RESET} $TERMUX_PKG_DESCRIPTION"
  if [[ ${#TERMUX_PKG_DESCRIPTION} -lt 15 ]]; then
    warn "Description is too short (<15 chars)"
  fi
else
  echo -e "${BOLD_RED}❌ TERMUX_PKG_DESCRIPTION:${RESET} (empty)"
  echo -e "   ${BOLD_YELLOW}💡 Suggestion:${RESET} Add a clear and descriptive package summary"
  RISK=1
fi

if [[ -n "${TERMUX_PKG_SHA256:-}" ]]; then
  if [[ ! "${TERMUX_PKG_SHA256}" =~ ^[a-fA-F0-9]{64}$ ]]; then
    warn "SHA256 format looks invalid (must be 64 hex characters)"
  fi
fi

if [[ -n "${TERMUX_PKG_SRCURL:-}" ]]; then
  if [[ ! "${TERMUX_PKG_SRCURL}" =~ ^https?:// ]]; then
    warn "SRCURL is not a valid HTTP/HTTPS URL"
  fi
fi

if [[ -n "${TERMUX_PKG_SRCURL:-}" ]]; then
  if [[ "${TERMUX_PKG_SRCURL}" =~ \.(tar\.gz|tar\.xz|zip|tgz)$ ]]; then
    info "Source type detected: Archive package"
  else
    warn "Source type detected: Raw binary (PyInstaller or prebuilt). This is acceptable for app-store style packages."
  fi
fi

if command -v curl >/dev/null 2>&1 && [[ -n "${TERMUX_PKG_SRCURL:-}" ]]; then
  echo
  echo -e "${CYAN}🌐 Remote Source Analysis${RESET}"
  echo -e "${CYAN}-------------------------------------------------${RESET}"

  HTTP_STATUS=$(curl -L -o /dev/null -s -w "%{http_code}" "$TERMUX_PKG_SRCURL" || echo "000")

  if [[ "$HTTP_STATUS" == "200" ]]; then
    echo -e "${BOLD_GREEN}✔ URL Status:${RESET} Reachable (HTTP 200)"
  else
    echo -e "${BOLD_RED}❌ URL Status:${RESET} Not reachable (HTTP $HTTP_STATUS)"
    echo -e "   ${BOLD_YELLOW}💡 Suggestion:${RESET} Check release URL or file existence"
    RISK=1
  fi

  FILE_SIZE=$(curl -sIL "$TERMUX_PKG_SRCURL" | grep -i content-length | tail -n1 | awk '{print $2}' | tr -d '\r')

  if [[ -n "$FILE_SIZE" && "$FILE_SIZE" =~ ^[0-9]+$ ]]; then
    SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $FILE_SIZE/1024/1024}")
    echo -e "${BOLD_GREEN}✔ Remote File Size:${RESET} ${SIZE_MB} MB (${FILE_SIZE} bytes)"

    if (( FILE_SIZE > 50000000 )); then
      warn "Very large package (>50MB). May be heavy for Termux users."
    elif (( FILE_SIZE > 15000000 )); then
      warn "Large binary (>15MB). Typical for PyInstaller builds."
    fi
  else
    warn "Could not detect remote file size (missing Content-Length header)"
  fi
fi

if [[ -n "${TERMUX_PKG_DEPENDS:-}" ]]; then
  echo
  echo -e "${CYAN}📦 Dependency Insight${RESET}"
  echo -e "${BOLD_GREEN}✔ TERMUX_PKG_DEPENDS:${RESET} $TERMUX_PKG_DEPENDS"

  if [[ "$TERMUX_PKG_DEPENDS" == *"python"* && ! "${TERMUX_PKG_SRCURL}" =~ \.(tar\.gz|zip)$ ]]; then
    warn "Package depends on python but source is a binary. Dependency may be unnecessary."
  fi
fi

echo
if [[ $RISK -eq 1 ]]; then
  echo -e "${BOLD_RED}🚫 High risk: PR likely to be rejected${RESET}"
elif [[ $WARN -eq 1 ]]; then
  echo -e "${BOLD_YELLOW}⚠️  Medium risk: PR may get reviewer comments${RESET}"
else
  echo -e "${BOLD_GREEN}🟢 Low risk: PR looks clean and review-friendly${RESET}"
fi

echo
echo -e "${CYAN}(Analysis only, no changes made)${RESET}"
