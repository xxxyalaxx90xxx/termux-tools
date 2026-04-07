TERMUX_PKG_HOMEPAGE=https://github.com/devxprite/infoooze
TERMUX_PKG_DESCRIPTION="A OSINT tool which helps you to quickly find information effectively."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-app-store"
TERMUX_PKG_VERSION=1.1.9
TERMUX_PKG_SRCURL=https://api.github.com/repos/devxprite/infoooze/tarball/v1.1.9
TERMUX_PKG_SHA256=b856ff7dc73ac57985372d833429c89cf03f52105039e48b71aee6d628abeb36
TERMUX_PKG_DEPENDS="nodejs"

termux_step_make_install() {
    local dest="$TERMUX_PREFIX/lib/node_modules/infoooze"
    rm -rf "$dest"
    cp -r "${TERMUX_PKG_SRCDIR:-$PWD}" "$dest"
    cd "$dest"
    npm install --production

    mkdir -p "$TERMUX_PREFIX/bin"
    cat > "$TERMUX_PREFIX/bin/infoooze" <<'WRAPPER'
#!/data/data/com.termux/files/usr/bin/bash
exec node /data/data/com.termux/files/usr/lib/node_modules/infoooze/index.js "$@"
WRAPPER
    chmod +x "$TERMUX_PREFIX/bin/infoooze"
}
