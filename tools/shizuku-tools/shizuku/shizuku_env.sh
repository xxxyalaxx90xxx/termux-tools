#!/data/data/com.termux/files/usr/bin/bash
# Shizuku environment setup

# Set rish application ID
export RISH_APPLICATION_ID=com.termux

# Create rish function
rish() {
    ~/rish "$@"
}

# Convenience functions for common Shizuku commands
spm() {
    rish -c "pm $*"
}

sam() {
    rish -c "am $*"
}

sdumpsys() {
    rish -c "dumpsys $*"
}

ssettings() {
    rish -c "settings $*"
}

sgetprop() {
    rish -c "getprop $*"
}

# Shizuku control functions
shizuku-start() {
    echo "Starting Shizuku..."
    rish -c 'sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
}

shizuku-status() {
    if rish -c 'pgrep -f shizuku_server' &>/dev/null; then
        echo "✓ Shizuku is running"
        return 0
    else
        echo "✗ Shizuku is not running"
        return 1
    fi
}

# Export all functions
export -f rish spm sam sdumpsys ssettings sgetprop shizuku-start shizuku-status

# Auto-check Shizuku on shell start
if [ -z "$SHIZUKU_CHECKED" ]; then
    export SHIZUKU_CHECKED=1
    echo -n "Checking Shizuku status... "
    shizuku-status
fi