#!/data/data/com.termux/files/usr/bin/bash
# Advanced fixes for Android 16

echo "Applying advanced Shizuku fixes..."

# Disable phantom process killing
if command -v device_config &> /dev/null; then
    device_config put activity_manager max_phantom_processes 2147483647 2>/dev/null
    device_config put activity_manager_native_boot max_phantom_processes 2147483647 2>/dev/null
fi

# Try to set Shizuku as device owner (requires specific conditions)
echo "Attempting to set device owner (may fail if not applicable)..."
dpm set-device-owner moe.shizuku.privileged.api/.ShizukuDeviceOwnerReceiver 2>/dev/null || \
echo "Device owner not set (normal if device is already set up)"

# Increase app importance
am make-uid-idle moe.shizuku.privileged.api 2>/dev/null
am set-standby-bucket moe.shizuku.privileged.api active 2>/dev/null

echo "Advanced fixes applied"
