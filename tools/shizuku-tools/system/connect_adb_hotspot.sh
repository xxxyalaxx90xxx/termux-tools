#!/data/data/com.termux/files/usr/bin/bash

echo "=== Connect ADB to Device Hotspot ==="
echo ""

# Method 1: Connect to localhost
echo "Method 1: Trying localhost connection..."
adb connect localhost:5555 2>/dev/null
if adb devices | grep -q "localhost:5555"; then
    echo "✓ Connected via localhost!"
else
    echo "✗ Localhost connection failed"
fi

# Method 2: Connect to 127.0.0.1
echo ""
echo "Method 2: Trying 127.0.0.1..."
adb connect 127.0.0.1:5555 2>/dev/null
if adb devices | grep -q "127.0.0.1:5555"; then
    echo "✓ Connected via 127.0.0.1!"
else
    echo "✗ 127.0.0.1 connection failed"
fi

# Method 3: Get hotspot IP
echo ""
echo "Method 3: Checking hotspot IP..."
HOTSPOT_IP=$(ip addr show 2>/dev/null | grep "inet 192.168.43" | awk '{print $2}' | cut -d/ -f1)
if [ -n "$HOTSPOT_IP" ]; then
    echo "Found hotspot IP: $HOTSPOT_IP"
    adb connect $HOTSPOT_IP:5555
else
    echo "Could not determine hotspot IP"
fi

# Method 4: Manual connection
echo ""
echo "Method 4: Manual connection"
echo "If above methods fail, try:"
echo "1. Go to Settings → About phone → Status → IP address"
echo "2. Or Settings → Wi-Fi → Current network → IP address"
echo "3. Then run: adb connect <your-ip>:5555"
echo ""
echo "For hotspot, the IP is usually:"
echo "  - 192.168.43.1 (Android default)"
echo "  - 192.168.1.1"
echo "  - 10.0.0.1"

# Check final connection status
echo ""
echo "Current ADB devices:"
adb devices