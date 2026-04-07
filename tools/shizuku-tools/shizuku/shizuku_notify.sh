#!/data/data/com.termux/files/usr/bin/bash
# Send notification about Shizuku status

if pgrep -f shizuku_server > /dev/null; then
    termux-notification -t "Shizuku Active" -c "Shizuku server is running" --id shizuku
else
    termux-notification -t "Shizuku Inactive" -c "Tap to start Shizuku" \
        --id shizuku \
        --action "termux-am start -n moe.shizuku.privileged.api/.MainActivity"
fi
