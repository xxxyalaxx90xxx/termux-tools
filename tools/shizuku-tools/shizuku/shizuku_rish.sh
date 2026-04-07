#!/data/data/com.termux/files/usr/bin/bash

# Shizuku management using rish
export RISH_APPLICATION_ID=com.termux

case "$1" in
    start)
        echo "Starting Shizuku server..."
        ./rish -c 'sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
        ;;
    stop)
        echo "Stopping Shizuku server..."
        ./rish -c 'pkill -f shizuku_server'
        ;;
    status)
        echo "Checking Shizuku status..."
        ./rish -c 'pgrep -f shizuku_server && echo "Shizuku is running" || echo "Shizuku is not running"'
        ;;
    test)
        echo "Testing Shizuku commands..."
        echo "1. Package list:"
        ./rish -c 'pm list packages | head -3'
        echo ""
        echo "2. System info:"
        ./rish -c 'getprop ro.build.version.release'
        ;;
    *)
        echo "Usage: $0 {start|stop|status|test}"
        ;;
esac