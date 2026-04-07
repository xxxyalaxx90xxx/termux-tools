#!/system/bin/sh
# Direct rish launcher for Shizuku

# Check if we're running via ADB
if [ -z "$ANDROID_DATA" ]; then
    echo "This script must be run via ADB shell"
    echo "Usage: adb shell sh $0 [command]"
    exit 1
fi

# The actual rish functionality
RISH_APK="/data/app/*/moe.shizuku.privileged.api*/base.apk"
SHIZUKU_DEX=$(ls $RISH_APK 2>/dev/null | head -1)

if [ -z "$SHIZUKU_DEX" ]; then
    echo "Shizuku is not installed"
    exit 1
fi

# Execute command with Shizuku privileges
if [ $# -eq 0 ]; then
    # Interactive mode
    sh
else
    # Command mode
    sh -c "$*"
fi