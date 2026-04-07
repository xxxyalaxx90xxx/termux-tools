#!/data/data/com.termux/files/usr/bin/bash

echo "=== Grant Termux Enhanced Privileges ==="
echo ""
echo "Since we can't make Termux a system app without root,"
echo "we'll grant it maximum possible permissions using Shizuku."
echo ""

export RISH_APPLICATION_ID=com.termux

# Grant all possible permissions
echo "Granting permissions..."
PERMISSIONS=(
    # Storage
    "android.permission.READ_EXTERNAL_STORAGE"
    "android.permission.WRITE_EXTERNAL_STORAGE"
    "android.permission.MANAGE_EXTERNAL_STORAGE"
    
    # Network
    "android.permission.INTERNET"
    "android.permission.ACCESS_NETWORK_STATE"
    "android.permission.ACCESS_WIFI_STATE"
    "android.permission.CHANGE_WIFI_STATE"
    
    # System info
    "android.permission.DUMP"
    "android.permission.PACKAGE_USAGE_STATS"
    "android.permission.GET_TASKS"
    
    # Development
    "android.permission.SET_DEBUG_APP"
    "android.permission.READ_LOGS"
    
    # Background
    "android.permission.FOREGROUND_SERVICE"
    "android.permission.WAKE_LOCK"
    "android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"
)

for perm in "${PERMISSIONS[@]}"; do
    echo -n "Granting $perm... "
    if ./rish -c "pm grant com.termux $perm" 2>/dev/null; then
        echo "✓"
    else
        echo "✗ (not grantable)"
    fi
done

# Set app standby bucket to active
echo ""
echo "Setting app standby bucket..."
./rish -c "am set-standby-bucket com.termux active"

# Disable battery optimizations
echo "Disabling battery optimizations..."
./rish -c "dumpsys deviceidle whitelist +com.termux"

# Allow background activity starts
echo "Allowing background activity..."
./rish -c "appops set com.termux RUN_IN_BACKGROUND allow"
./rish -c "appops set com.termux RUN_ANY_IN_BACKGROUND allow"

# Grant special app ops
echo ""
echo "Setting special app operations..."
APP_OPS=(
    "PROJECT_MEDIA allow"
    "START_FOREGROUND allow"
    "SYSTEM_ALERT_WINDOW allow"
    "GET_USAGE_STATS allow"
    "PACKAGE_USAGE_STATS allow"
)

for op in "${APP_OPS[@]}"; do
    echo "Setting: $op"
    ./rish -c "appops set com.termux $op" 2>/dev/null || true
done

# Check results
echo ""
echo "=== Current Status ==="
echo ""
echo "Permissions granted:"
./rish -c "dumpsys package com.termux | grep -E 'permission.*granted=true' | grep -v 'android.permission.(INTERNET|VIBRATE|WAKE_LOCK)' | head -10"

echo ""
echo "Battery optimization:"
./rish -c "dumpsys deviceidle | grep com.termux" || echo "Not whitelisted"

echo ""
echo "✅ Termux now has enhanced privileges!"
echo "Note: While not a true system app, it has many system-level permissions."