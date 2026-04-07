#!/data/data/com.termux/files/usr/bin/bash

echo "=== Lucky Patcher App Analyzer ==="
echo ""

export RISH_APPLICATION_ID=com.termux

PKG="${1}"
if [ -z "$PKG" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

echo "Analyzing: $PKG"
echo ""

# Check if app exists
if ! ./rish -c "pm list packages | grep -q $PKG" 2>/dev/null; then
    echo "Package not found!"
    exit 1
fi

# Get app info
echo "App Info:"
./rish -c "dumpsys package $PKG | grep -E '(versionName|versionCode|targetSdk)' | head -3" 2>/dev/null

echo ""
echo "Patchable Components:"

# Check for billing
echo ""
echo "📱 In-App Purchases:"
BILLING=$(./rish -c "dumpsys package $PKG | grep -E '(billing|purchase|iab|InAppBilling)'" 2>/dev/null | wc -l)
if [ $BILLING -gt 0 ]; then
    echo "  ✓ Has in-app purchases ($BILLING components)"
    ./rish -c "dumpsys package $PKG | grep -E '(billing|purchase)' | head -3" 2>/dev/null
else
    echo "  ✗ No in-app purchases detected"
fi

# Check for ads
echo ""
echo "📢 Advertisements:"
ADS=$(./rish -c "dumpsys package $PKG | grep -E '(ads|admob|adsense|unity3d.ads|facebook.ads|applovin|vungle)'" 2>/dev/null | wc -l)
if [ $ADS -gt 0 ]; then
    echo "  ✓ Has advertisements ($ADS components)"
    ./rish -c "dumpsys package $PKG | grep -E '(ads|admob)' | head -3" 2>/dev/null
else
    echo "  ✗ No ads detected"
fi

# Check for analytics
echo ""
echo "📊 Analytics/Tracking:"
ANALYTICS=$(./rish -c "dumpsys package $PKG | grep -E '(analytics|firebase|crashlytics|flurry|mixpanel)'" 2>/dev/null | wc -l)
if [ $ANALYTICS -gt 0 ]; then
    echo "  ✓ Has analytics ($ANALYTICS components)"
    ./rish -c "dumpsys package $PKG | grep -E '(analytics|firebase)' | head -3" 2>/dev/null
else
    echo "  ✗ No analytics detected"
fi

# Check for license verification
echo ""
echo "🔒 License Verification:"
LICENSE=$(./rish -c "dumpsys package $PKG | grep -E '(license|lvl|LicenseChecker)'" 2>/dev/null | wc -l)
if [ $LICENSE -gt 0 ]; then
    echo "  ✓ Has license checks ($LICENSE components)"
else
    echo "  ✗ No license checks detected"
fi

# Recommendations
echo ""
echo "Recommended Actions:"
[ $BILLING -gt 0 ] && echo "  • Remove in-app purchases: ./lp_ultimate.sh super-patch $PKG"
[ $ADS -gt 0 ] && echo "  • Remove ads: ./lp_advanced.sh disable-analytics $PKG"
[ $ANALYTICS -gt 0 ] && echo "  • Remove tracking: ./lp_advanced.sh disable-analytics $PKG"
[ $LICENSE -gt 0 ] && echo "  • Remove license: ./lp_ultimate.sh remove-license $PKG"

echo ""
echo "Quick patch: ./lp_ultimate.sh super-patch $PKG"