TERMUX_PKG_HOMEPAGE=https://github.com/GiorgosXou/TUIFIManager
TERMUX_PKG_DESCRIPTION="A terminal-based TUI file manager"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-app-store"
TERMUX_PKG_VERSION=5.2.6
TERMUX_PKG_SRCURL=https://api.github.com/repos/GiorgosXou/TUIFIManager/tarball/v.${TERMUX_PKG_VERSION}
TERMUX_PKG_SHA256=4f323aefd84e35177411445c32ed2d48140b0fd1fec688bbcdee0992841e0f00
TERMUX_PKG_DEPENDS="python"

termux_step_make_install() {
    cd "${TERMUX_PKG_SRCDIR:-$PWD}"
    pip install . --break-system-packages -q

    mkdir -p "$TERMUX_PREFIX/bin"
    cat > "$TERMUX_PREFIX/bin/tuifimanager" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec python3 -m TUIFIManager "$@"
EOF
    chmod +x "$TERMUX_PREFIX/bin/tuifimanager"
}
