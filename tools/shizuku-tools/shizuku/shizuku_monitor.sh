#!/data/data/com.termux/files/usr/bin/bash
# Monitor and notify about Shizuku status

check_shizuku() {
    if pgrep -f "shizuku_server" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Initial check
LAST_STATE=$(check_shizuku && echo "running" || echo "stopped")

while true; do
    if check_shizuku; then
        CURRENT_STATE="running"
    else
        CURRENT_STATE="stopped"
        # Try to restart
        am start-activity -n moe.shizuku.privileged.api/.MainActivity 2>/dev/null
    fi
    
    # Notify on state change
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" = "stopped" ]; then
            termux-notification -t "Shizuku Died" \
                -c "Attempting to restart..." \
                --priority high \
                --id shizuku-monitor
        else
            termux-notification -t "Shizuku Recovered" \
                -c "Service is running again" \
                --id shizuku-monitor
        fi
        LAST_STATE=$CURRENT_STATE
    fi
    
    sleep 60  # Check every minute
done
