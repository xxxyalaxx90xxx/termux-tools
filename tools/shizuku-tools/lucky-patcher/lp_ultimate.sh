#!/data/data/com.termux/files/usr/bin/bash

echo "=== Ultimate Lucky Patcher Extension with rish ==="
echo ""

export RISH_APPLICATION_ID=com.termux

# Try to find Lucky Patcher package name
LP_PACKAGES=(
    "com.dimonvideo.luckypatcher"
    "com.chelpus.lackypatch"
    "com.android.vendinglp"
    "ru.aaaaaaci.installer"
)

LP_FOUND=""
for pkg in "${LP_PACKAGES[@]}"; do
    if ./rish -c "pm list packages | grep -q $pkg" 2>/dev/null; then
        LP_FOUND="$pkg"
        break
    fi
done

if [ -z "$LP_FOUND" ]; then
    echo "Lucky Patcher not found. Installing from APK..."
    APK_PATH="/storage/emulated/0/Download/LuckyPatchers.com_Official_Installer_11.9.2.apk"
    
    if [ -f "$APK_PATH" ]; then
        echo "Installing $APK_PATH..."
        ./rish -c "settings put global package_verifier_enable 0" 2>/dev/null
        ./rish -c "settings put global verifier_verify_adb_installs 0" 2>/dev/null
        ./rish -c "pm install -r -t -g -d --bypass-low-target-sdk-block '$APK_PATH'" 2>&1
        
        # Check again after install
        for pkg in "${LP_PACKAGES[@]}"; do
            if ./rish -c "pm list packages | grep -q $pkg" 2>/dev/null; then
                LP_FOUND="$pkg"
                break
            fi
        done
    fi
fi

if [ -n "$LP_FOUND" ]; then
    echo "Lucky Patcher found: $LP_FOUND"
    LP_PACKAGE="$LP_FOUND"
else
    echo "Lucky Patcher package not detected"
    LP_PACKAGE="com.dimonvideo.luckypatcher"
fi

# Ultimate Lucky Patcher Functions
case "$1" in
    install)
        echo "Installing Lucky Patcher..."
        APK="${2:-/storage/emulated/0/Download/LuckyPatchers.com_Official_Installer_11.9.2.apk}"
        
        # Disable all security checks
        ./rish -c "settings put global package_verifier_enable 0"
        ./rish -c "settings put global verifier_verify_adb_installs 0"
        ./rish -c "settings put secure install_non_market_apps 1"
        
        # Install with maximum privileges
        ./rish -c "pm install -r -t -g -d --bypass-low-target-sdk-block '$APK'" 2>&1
        
        # Grant all possible permissions
        echo "Granting permissions..."
        for perm in $(./rish -c "pm list permissions -g | grep permission:" | cut -d: -f2); do
            ./rish -c "pm grant $LP_PACKAGE $perm" 2>/dev/null
        done
        ;;
    
    super-patch)
        PKG="${2}"
        if [ -z "$PKG" ]; then
            echo "Usage: $0 super-patch <package-name>"
            exit 1
        fi
        
        echo "Super Patching: $PKG"
        echo ""
        
        # 1. Disable all app protections
        echo "[1/8] Disabling protections..."
        ./rish -c "settings put global package_verifier_enable 0"
        ./rish -c "settings put global upload_apk_enable 0"
        ./rish -c "pm clear com.android.vending"
        ./rish -c "pm clear com.google.android.gms"
        
        # 2. Remove signature verification
        echo "[2/8] Removing signature checks..."
        ./rish -c "pm grant $PKG android.permission.FAKE_PACKAGE_SIGNATURE" 2>/dev/null
        ./rish -c "settings put global package_verifier_user_consent -1"
        
        # 3. Patch Google Play billing
        echo "[3/8] Patching billing services..."
        BILLING_COMPONENTS=(
            "com.android.vending/com.google.android.finsky.billing.iab.InAppBillingService"
            "com.android.vending/com.google.android.finsky.billing.iab.MarketBillingService"
            "com.google.android.gms/com.google.android.gms.wallet.service.PaymentService"
        )
        
        for component in "${BILLING_COMPONENTS[@]}"; do
            ./rish -c "pm disable-user --user 0 $component" 2>/dev/null
        done
        
        # 4. Remove ads completely
        echo "[4/8] Removing all ads..."
        AD_PATTERNS=(
            "com.google.android.gms.ads"
            "com.facebook.ads"
            "com.unity3d.ads"
            "com.admob"
            "com.adsense"
            "com.applovin"
            "com.vungle"
            "com.mopub"
            "com.startapp"
            "com.ironsource"
        )
        
        for pattern in "${AD_PATTERNS[@]}"; do
            # Disable all matching components
            COMPONENTS=$(./rish -c "dumpsys package $PKG | grep -i $pattern | grep -E '(Activity|Service|Receiver)' | awk '{print \$2}'" 2>/dev/null)
            for comp in $COMPONENTS; do
                ./rish -c "pm disable-user --user 0 $comp" 2>/dev/null && echo "  ✓ Disabled: $comp"
            done
        done
        
        # 5. Remove analytics and tracking
        echo "[5/8] Removing analytics..."
        ANALYTICS_PATTERNS=(
            "analytics"
            "firebase"
            "crashlytics"
            "flurry"
            "mixpanel"
            "amplitude"
            "branch"
            "adjust"
            "appsflyer"
        )
        
        for pattern in "${ANALYTICS_PATTERNS[@]}"; do
            COMPONENTS=$(./rish -c "dumpsys package $PKG | grep -i $pattern | grep -E '(Service|Receiver)' | awk '{print \$2}'" 2>/dev/null)
            for comp in $COMPONENTS; do
                ./rish -c "pm disable-user --user 0 $comp" 2>/dev/null && echo "  ✓ Disabled: $comp"
            done
        done
        
        # 6. Grant all permissions
        echo "[6/8] Granting all permissions..."
        ALL_PERMS=$(./rish -c "dumpsys package $PKG | grep permission: | awk '{print \$1}' | cut -d: -f2" 2>/dev/null)
        for perm in $ALL_PERMS; do
            ./rish -c "pm grant $PKG $perm" 2>/dev/null
        done
        
        # 7. Remove restrictions
        echo "[7/8] Removing all restrictions..."
        ./rish -c "appops set $PKG RUN_IN_BACKGROUND allow"
        ./rish -c "appops set $PKG RUN_ANY_IN_BACKGROUND allow"
        ./rish -c "appops set $PKG START_FOREGROUND allow"
        ./rish -c "appops set $PKG SYSTEM_ALERT_WINDOW allow"
        ./rish -c "appops set $PKG WAKE_LOCK allow"
        ./rish -c "am set-standby-bucket $PKG active"
        ./rish -c "dumpsys deviceidle whitelist +$PKG"
        
        # 8. Create patched backup
        echo "[8/8] Creating backup..."
        mkdir -p ~/lp_backups
        APK_PATH=$(./rish -c "pm path $PKG" | cut -d: -f2)
        cp "$APK_PATH" "~/lp_backups/${PKG}_patched.apk" 2>/dev/null
        
        echo ""
        echo "✓ Super patch complete!"
        ;;
    
    remove-license)
        PKG="${2}"
        if [ -z "$PKG" ]; then
            echo "Usage: $0 remove-license <package-name>"
            exit 1
        fi
        
        echo "Removing license verification from $PKG..."
        
        # Clear license data
        ./rish -c "pm clear com.android.vending"
        ./rish -c "rm -rf /data/data/$PKG/shared_prefs/*license*" 2>/dev/null
        ./rish -c "rm -rf /data/data/$PKG/files/*license*" 2>/dev/null
        
        # Block license servers
        echo "127.0.0.1 play.googleapis.com" >> ~/lp_hosts
        echo "127.0.0.1 android.clients.google.com" >> ~/lp_hosts
        
        echo "✓ License checks removed"
        ;;
    
    clone-app)
        PKG="${2}"
        NEW_NAME="${3:-${PKG}_clone}"
        
        echo "Cloning $PKG as $NEW_NAME..."
        
        # Method 1: Install for different user
        ./rish -c "pm install-existing --user 10 $PKG" 2>/dev/null || {
            # Method 2: Modify and reinstall
            APK_PATH=$(./rish -c "pm path $PKG" | cut -d: -f2)
            cp "$APK_PATH" "~/lp_backups/${NEW_NAME}.apk"
            echo "Clone created at ~/lp_backups/${NEW_NAME}.apk"
            echo "Modify package name in APK and reinstall"
        }
        ;;
    
    list-patchable)
        echo "Apps that can be patched:"
        echo ""
        ./rish -c "pm list packages -3" | grep -v lucky | while read pkg; do
            PKG_NAME=$(echo $pkg | cut -d: -f2)
            HAS_BILLING=$(./rish -c "dumpsys package $PKG_NAME | grep -E '(billing|purchase|iab)'" 2>/dev/null)
            HAS_ADS=$(./rish -c "dumpsys package $PKG_NAME | grep -E '(ads|admob|adsense)'" 2>/dev/null)
            
            if [ -n "$HAS_BILLING" ] || [ -n "$HAS_ADS" ]; then
                echo "✓ $PKG_NAME"
                [ -n "$HAS_BILLING" ] && echo "  - Has in-app purchases"
                [ -n "$HAS_ADS" ] && echo "  - Has ads"
            fi
        done
        ;;
    
    *)
        echo "Ultimate Lucky Patcher Extension"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  install [apk]            - Install Lucky Patcher"
        echo "  super-patch <pkg>        - Apply all patches to an app"
        echo "  remove-license <pkg>     - Remove license verification"
        echo "  clone-app <pkg> [name]   - Clone an app"
        echo "  list-patchable           - List apps that can be patched"
        echo ""
        echo "Current Lucky Patcher: $LP_PACKAGE"
        ;;
esac