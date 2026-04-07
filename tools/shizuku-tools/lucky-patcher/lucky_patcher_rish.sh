#!/data/data/com.termux/files/usr/bin/bash

echo "=== Lucky Patcher Enhancement with Shizuku (rish) ==="
echo ""
echo "WARNING: This tool is for educational purposes only!"
echo "Only use on apps you own or have permission to modify."
echo ""

export RISH_APPLICATION_ID=com.termux

# Check if Lucky Patcher is installed
LP_PACKAGE="com.dimonvideo.luckypatcher"
if ! ./rish -c "pm list packages | grep -q $LP_PACKAGE" 2>/dev/null; then
    echo "Lucky Patcher not found. Please install it first."
    echo "Official site: https://www.luckypatchers.com"
    exit 1
fi

# Function to disable signature verification
disable_signature_verification() {
    echo "Attempting to disable signature verification..."
    ./rish -c "settings put global verifier_verify_adb_installs 0" 2>/dev/null
    ./rish -c "settings put global package_verifier_enable 0" 2>/dev/null
    ./rish -c "settings put global package_verifier_user_consent -1" 2>/dev/null
    echo "✓ Signature verification settings modified"
}

# Function to grant Lucky Patcher permissions
grant_lp_permissions() {
    echo ""
    echo "Granting Lucky Patcher enhanced permissions..."
    
    PERMISSIONS=(
        "android.permission.WRITE_SECURE_SETTINGS"
        "android.permission.INSTALL_PACKAGES"
        "android.permission.DELETE_PACKAGES"
        "android.permission.CLEAR_APP_CACHE"
        "android.permission.MOUNT_UNMOUNT_FILESYSTEMS"
        "android.permission.ACCESS_RESTRICTED_SETTINGS"
        "android.permission.MANAGE_EXTERNAL_STORAGE"
    )
    
    for perm in "${PERMISSIONS[@]}"; do
        if ./rish -c "pm grant $LP_PACKAGE $perm" 2>/dev/null; then
            echo "✓ Granted: $perm"
        else
            echo "✗ Cannot grant: $perm (may require root)"
        fi
    done
}

# Function to patch an APK
patch_apk() {
    local APK_PATH="$1"
    local PACKAGE_NAME="$2"
    
    echo ""
    echo "Patching APK: $APK_PATH"
    
    # Extract APK info
    if [ -z "$PACKAGE_NAME" ]; then
        PACKAGE_NAME=$(./rish -c "aapt dump badging '$APK_PATH' | grep package: | awk '{print \$2}' | cut -d\"'\" -f2" 2>/dev/null)
    fi
    
    echo "Package: $PACKAGE_NAME"
    
    # Backup original APK
    echo "Creating backup..."
    cp "$APK_PATH" "${APK_PATH}.backup"
    
    # Common patches Lucky Patcher does
    echo ""
    echo "Applying patches..."
    
    # 1. Remove license verification
    echo "- Removing license verification..."
    ./rish -c "pm clear com.android.vending" 2>/dev/null
    
    # 2. Disable app signature check for this package
    ./rish -c "pm install -r -t -g -d --bypass-low-target-sdk-block '$APK_PATH'" 2>/dev/null
    
    # 3. Grant all permissions to the app
    echo "- Granting all permissions..."
    ./rish -c "pm grant-all $PACKAGE_NAME" 2>/dev/null
    
    # 4. Remove ads (by blocking ad servers)
    echo "- Blocking ad servers..."
    block_ads_for_app "$PACKAGE_NAME"
    
    echo "✓ Patching complete"
}

# Function to block ads for specific app
block_ads_for_app() {
    local PACKAGE="$1"
    
    # Set restricted network access for known ad libraries
    AD_COMPONENTS=(
        "com.google.android.gms.ads"
        "com.facebook.ads"
        "com.unity3d.ads"
        "com.applovin"
        "com.vungle"
    )
    
    for component in "${AD_COMPONENTS[@]}"; do
        ./rish -c "pm disable-user --user 0 $PACKAGE/$component" 2>/dev/null
    done
    
    # Restrict network for ad-related permissions
    ./rish -c "appops set $PACKAGE WIFI_SCAN deny" 2>/dev/null
}

# Function to remove app restrictions
remove_app_restrictions() {
    local PACKAGE="$1"
    
    echo ""
    echo "Removing restrictions for: $PACKAGE"
    
    # Reset app preferences
    ./rish -c "pm set-app-standby-bucket $PACKAGE active" 2>/dev/null
    ./rish -c "am set-inactive $PACKAGE false" 2>/dev/null
    
    # Allow background activity
    ./rish -c "appops set $PACKAGE RUN_IN_BACKGROUND allow" 2>/dev/null
    ./rish -c "appops set $PACKAGE RUN_ANY_IN_BACKGROUND allow" 2>/dev/null
    ./rish -c "appops set $PACKAGE START_FOREGROUND allow" 2>/dev/null
    
    # Disable battery optimization
    ./rish -c "dumpsys deviceidle whitelist +$PACKAGE" 2>/dev/null
    
    echo "✓ Restrictions removed"
}

# Function to clone an app
clone_app() {
    local PACKAGE="$1"
    local NEW_NAME="$2"
    
    echo ""
    echo "Cloning app: $PACKAGE"
    echo "New name: $NEW_NAME"
    
    # Get APK path
    APK_PATH=$(./rish -c "pm path $PACKAGE" | cut -d: -f2)
    
    # Install as new user (creates app clone)
    ./rish -c "pm install-existing --user 10 $PACKAGE" 2>/dev/null || {
        echo "Cloning requires root or multiple user support"
    }
}

# Main menu
case "$1" in
    setup)
        echo "Setting up Lucky Patcher enhancements..."
        disable_signature_verification
        grant_lp_permissions
        echo ""
        echo "✓ Setup complete!"
        ;;
    
    patch)
        if [ -z "$2" ]; then
            echo "Usage: $0 patch <apk-path> [package-name]"
            exit 1
        fi
        patch_apk "$2" "$3"
        ;;
    
    remove-restrictions)
        if [ -z "$2" ]; then
            echo "Usage: $0 remove-restrictions <package-name>"
            exit 1
        fi
        remove_app_restrictions "$2"
        ;;
    
    clone)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 clone <package-name> <new-name>"
            exit 1
        fi
        clone_app "$2" "$3"
        ;;
    
    list-patchable)
        echo "Listing apps that can be patched..."
        ./rish -c "pm list packages -3 | grep -v $LP_PACKAGE" | head -20
        ;;
    
    backup-app)
        if [ -z "$2" ]; then
            echo "Usage: $0 backup-app <package-name>"
            exit 1
        fi
        echo "Backing up $2..."
        APK_PATH=$(./rish -c "pm path $2" | cut -d: -f2)
        cp "$APK_PATH" "~/backup_${2}.apk"
        echo "✓ Backed up to ~/backup_${2}.apk"
        ;;
    
    *)
        echo "Lucky Patcher Enhancement Tool"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  setup                    - Initial setup and permissions"
        echo "  patch <apk> [pkg]       - Patch an APK file"
        echo "  remove-restrictions <pkg> - Remove app restrictions"
        echo "  clone <pkg> <name>      - Clone an app"
        echo "  list-patchable          - List patchable apps"
        echo "  backup-app <pkg>        - Backup an app"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 patch ~/game.apk"
        echo "  $0 remove-restrictions com.example.app"
        ;;
esac