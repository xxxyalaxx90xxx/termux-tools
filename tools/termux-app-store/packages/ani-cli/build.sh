TERMUX_PKG_HOMEPAGE=https://github.com/pystardust/ani-cli
TERMUX_PKG_DESCRIPTION="A cli tool to browse and play anime"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-app-store"
TERMUX_PKG_VERSION=4.10
TERMUX_PKG_SRCURL=https://github.com/pystardust/ani-cli/releases/download/v${TERMUX_PKG_VERSION}/ani-cli
TERMUX_PKG_SHA256=38599dc5bb65a5b9f78e936ed42ffe16b62095dbc6621a5b578ed3e29aac4f3e
TERMUX_PKG_DEPENDS="nodejs"

termux_step_make_install() {
    npm install -g --prefix "$TERMUX_PREFIX" "$TERMUX_PKG_SRCDIR"

    if [ ! -f "$TERMUX_PREFIX/bin/ani-cli" ]; then
        cd "$TERMUX_PKG_SRCDIR"
        npm install --production
        npm link
    fi
}
