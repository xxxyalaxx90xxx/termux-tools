TERMUX_PKG_HOMEPAGE=https://github.com/bower/bower
TERMUX_PKG_DESCRIPTION="A package manager for the web"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-app-store"
TERMUX_PKG_VERSION=1.8.12
TERMUX_PKG_SRCURL=https://api.github.com/repos/bower/bower/tarball/v${TERMUX_PKG_VERSION}
TERMUX_PKG_SHA256=d54d92c4a12c674e79ed38742bd82b797098c24e67391c963555cf4a23855e01
TERMUX_PKG_DEPENDS="nodejs"

termux_step_make_install() {
    local dest="$TERMUX_PREFIX/lib/node_modules/bower"
    rm -rf "$dest"
    cp -r "${TERMUX_PKG_SRCDIR:-$PWD}" "$dest"
    cd "$dest"
    npm install --production 2>/dev/null || true

    mkdir -p "$TERMUX_PREFIX/bin"
    cat > "$TERMUX_PREFIX/bin/bower" <<'EOF'
#!/data/data/com.termux/files/usr/bin/node
require('/data/data/com.termux/files/usr/lib/node_modules/bower/lib/bin/bower');
EOF
    chmod +x "$TERMUX_PREFIX/bin/bower"
}
