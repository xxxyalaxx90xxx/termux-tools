#!/data/data/com.termux/files/usr/bin/bash

echo "Setting up Wireless ADB with Shizuku..."

# Check if Shizuku is running
if ! adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh 2>/dev/null | grep -q "shizuku_starter exit with 0"; then
    echo "Starting Shizuku service..."
    adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
    sleep 3
fi

# Enable wireless ADB on port 5555
echo "Enabling wireless ADB on port 5555..."
adb tcpip 5555
sleep 2

# Get device IP
IP=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -z "$IP" ]; then
    echo "Could not determine device IP. Please check WiFi connection."
    echo "You can manually connect using: adb connect <device-ip>:5555"
else
    echo "Device IP: $IP"
    echo "Connecting to wireless ADB..."
    adb connect $IP:5555
fi

echo ""
echo "Wireless ADB setup complete!"
echo "To reconnect later, use: adb connect $IP:5555"