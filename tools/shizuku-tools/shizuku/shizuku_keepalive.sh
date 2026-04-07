#!/data/data/com.termux/files/usr/bin/bash
# Shizuku keep-alive daemon

LOGFILE=~/.shizuku_keepalive.log

while true; do
    if ! pgrep -f "shizuku_server" > /dev/null; then
        echo "$(date): Shizuku died, restarting..." >> $LOGFILE
        
        # Try multiple methods to restart
        am start-activity -n moe.shizuku.privileged.api/.MainActivity 2>/dev/null || \
        termux-am start -n moe.shizuku.privileged.api/.MainActivity 2>/dev/null
        
        sleep 5
        
        # Start Shizuku service
        am broadcast -a moe.shizuku.manager.action.REQUEST_START 2>/dev/null
    fi
    
    sleep 30  # Check every 30 seconds
done
