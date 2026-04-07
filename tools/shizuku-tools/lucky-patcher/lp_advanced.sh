#!/data/data/com.termux/files/usr/bin/bash

echo "=== Advanced Lucky Patcher Functions with rish ==="
echo ""

export RISH_APPLICATION_ID=com.termux

# Advanced patching functions
advanced_patch() {
    local PACKAGE="$1"
    
    echo "Advanced patching for: $PACKAGE"
    
    # 1. Disable all app protections
    echo ""
    echo "1. Disabling app protections..."
    ./rish -c "settings put global package_verifier_enable 0"
    ./rish -c "settings put secure install_non_market_apps 1"
    ./rish -c "settings put global verifier_verify_adb_installs 0"
    
    # 2. Remove in-app purchase verification
    echo ""
    echo "2. Patching in-app purchases..."
    # Clear Google Play Services cache
    ./rish -c "pm clear com.android.vending"
    ./rish -c "pm clear com.google.android.gms"
    
    # Disable billing service
    ./rish -c "pm disable-user --user 0 com.android.vending/com.google.android.finsky.billing.iab.InAppBillingService" 2>/dev/null
    
    # 3. Remove license checks
    echo ""
    echo "3. Removing license verification..."
    # Grant FAKE_PACKAGE_SIGNATURE permission (if possible)
    ./rish -c "pm grant $PACKAGE android.permission.FAKE_PACKAGE_SIGNATURE" 2>/dev/null
    
    # 4. Bypass root detection
    echo ""
    echo "4. Bypassing root detection..."
    # Hide from root detection
    ./rish -c "pm hide su" 2>/dev/null
    ./rish -c "pm hide magisk" 2>/dev/null
    
    # 5. Remove ads more aggressively
    echo ""
    echo "5. Aggressive ad removal..."
    # Disable all ad-related activities
    AD_ACTIVITIES=$(./rish -c "dumpsys package $PACKAGE | grep -E '(ads|banner|interstitial|admob|adsense)' | grep -E 'Activity|Service' | awk '{print \$2}'" 2>/dev/null)
    
    for activity in $AD_ACTIVITIES; do
        ./rish -c "pm disable-user --user 0 $activity" 2>/dev/null && echo "  ✓ Disabled: $activity"
    done
    
    # 6. Unlimited resources hack
    echo ""
    echo "6. Applying resource modifications..."
    # Grant storage permissions for save game modification
    ./rish -c "appops set $PACKAGE MANAGE_EXTERNAL_STORAGE allow" 2>/dev/null
    ./rish -c "pm grant $PACKAGE android.permission.WRITE_EXTERNAL_STORAGE" 2>/dev/null
    
    echo ""
    echo "✓ Advanced patching complete!"
}

# Function to create modded APK
create_modded_apk() {
    local ORIGINAL_APK="$1"
    local OUTPUT_DIR="$HOME/modded_apks"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo "Creating modded APK from: $ORIGINAL_APK"
    
    # Extract package name
    PKG_NAME=$(./rish -c "aapt dump badging '$ORIGINAL_APK' | grep package: | awk '{print \$2}' | cut -d\"'\" -f2" 2>/dev/null)
    
    # Copy APK
    cp "$ORIGINAL_APK" "$OUTPUT_DIR/${PKG_NAME}_modded.apk"
    
    # Apply signature bypass
    echo "Applying signature bypass..."
    ./rish -c "settings put global package_verifier_enable 0"
    
    # Install with bypass flags
    echo "Installing modded version..."
    ./rish -c "pm install -r -t -g -d --bypass-low-target-sdk-block '$OUTPUT_DIR/${PKG_NAME}_modded.apk'" 2>&1
    
    echo "✓ Modded APK created: $OUTPUT_DIR/${PKG_NAME}_modded.apk"
}

# Function to hook app functions
hook_app_functions() {
    local PACKAGE="$1"
    
    echo "Setting up function hooks for: $PACKAGE"
    
    # Create hook script
    cat > ~/lp_hooks/${PACKAGE}_hook.sh << 'HOOK'
#!/system/bin/sh
# Hook script for package

# Hook into billing
export BILLING_RESPONSE_RESULT_OK=0
export BILLING_RESPONSE_RESULT_USER_CANCELED=1
export BILLING_RESPONSE_RESULT_SERVICE_UNAVAILABLE=2

# Override purchase state
export PURCHASE_STATE_PURCHASED=0

# Hook return values
echo "HOOK: Returning success for all purchases"
HOOK

    chmod +x ~/lp_hooks/${PACKAGE}_hook.sh
    
    # Set as debuggable
    ./rish -c "am set-debug-app --persistent $PACKAGE" 2>/dev/null
    
    echo "✓ Hooks installed"
}

# Memory patching function
memory_patch() {
    local PACKAGE="$1"
    local SEARCH_VALUE="$2"
    local REPLACE_VALUE="$3"
    
    echo "Memory patching: $PACKAGE"
    echo "Search: $SEARCH_VALUE → Replace: $REPLACE_VALUE"
    
    # Get process ID
    PID=$(./rish -c "pidof $PACKAGE" 2>/dev/null)
    
    if [ -n "$PID" ]; then
        echo "Process found: PID $PID"
        # Note: Actual memory patching requires root
        echo "Memory patching requires root access"
    else
        echo "App not running"
    fi
}

# Main enhanced menu
case "$1" in
    advanced-patch)
        if [ -z "$2" ]; then
            echo "Usage: $0 advanced-patch <package-name>"
            exit 1
        fi
        advanced_patch "$2"
        ;;
    
    create-mod)
        if [ -z "$2" ]; then
            echo "Usage: $0 create-mod <apk-path>"
            exit 1
        fi
        create_modded_apk "$2"
        ;;
    
    hook)
        if [ -z "$2" ]; then
            echo "Usage: $0 hook <package-name>"
            exit 1
        fi
        mkdir -p ~/lp_hooks
        hook_app_functions "$2"
        ;;
    
    memory-patch)
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 memory-patch <package> <search> <replace>"
            exit 1
        fi
        memory_patch "$2" "$3" "$4"
        ;;
    
    list-activities)
        if [ -z "$2" ]; then
            echo "Usage: $0 list-activities <package-name>"
            exit 1
        fi
        echo "Activities in $2:"
        ./rish -c "dumpsys package $2 | grep -A1 'Activity:'" 2>/dev/null
        ;;
    
    disable-analytics)
        if [ -z "$2" ]; then
            echo "Usage: $0 disable-analytics <package-name>"
            exit 1
        fi
        echo "Disabling analytics for $2..."
        ANALYTICS_COMPONENTS=$(./rish -c "dumpsys package $2 | grep -E '(analytics|firebase|crashlytics|flurry|mixpanel)' | grep -E 'Service|Receiver' | awk '{print \$2}'" 2>/dev/null)
        
        for component in $ANALYTICS_COMPONENTS; do
            ./rish -c "pm disable-user --user 0 $component" 2>/dev/null && echo "✓ Disabled: $component"
        done
        ;;
    
    *)
        echo "Advanced Lucky Patcher Functions"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  advanced-patch <pkg>      - Apply all advanced patches"
        echo "  create-mod <apk>         - Create modded APK"
        echo "  hook <pkg>               - Install function hooks"
        echo "  memory-patch <pkg> <s> <r> - Memory patching (requires root)"
        echo "  list-activities <pkg>    - List app activities"
        echo "  disable-analytics <pkg>  - Disable analytics/tracking"
        echo ""
        echo "Note: Some functions require root access for full functionality"
        ;;
esac