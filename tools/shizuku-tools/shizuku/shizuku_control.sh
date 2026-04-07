#!/data/data/com.termux/files/usr/bin/bash
# Shizuku control center

case "$1" in
    start)
        echo "Starting Shizuku..."
        am start-activity -n moe.shizuku.privileged.api/.MainActivity
        ;;
    stop)
        echo "Stopping Shizuku..."
        pkill -f shizuku_server
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        if pgrep -f shizuku_server > /dev/null; then
            echo "Shizuku is running (PID: $(pgrep -f shizuku_server))"
        else
            echo "Shizuku is not running"
        fi
        ;;
    keepalive)
        echo "Starting keep-alive daemon..."
        nohup ~/shizuku_keepalive.sh > /dev/null 2>&1 &
        echo "Keep-alive started (PID: $!)"
        ;;
    monitor)
        echo "Starting monitor..."
        ~/shizuku_monitor.sh
        ;;
    fix)
        ~/shizuku_advanced_fix.sh
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|keepalive|monitor|fix}"
        exit 1
        ;;
esac
