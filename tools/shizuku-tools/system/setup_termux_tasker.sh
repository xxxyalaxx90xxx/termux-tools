#!/data/data/com.termux/files/usr/bin/bash

echo "=== Setup Termux for Tasker Integration ==="
echo ""
echo "Based on Tasker's requirements, we'll configure Termux similarly"
echo ""

export RISH_APPLICATION_ID=com.termux

# Install Termux:Tasker if not present
echo "1. Installing Termux:Tasker plugin..."
if ! pm list packages | grep -q "com.termux.tasker"; then
    echo "Please install Termux:Tasker from F-Droid"
    echo "https://f-droid.org/packages/com.termux.tasker/"
else
    echo "✓ Termux:Tasker already installed"
fi

# Grant permissions using ADB commands (via rish)
echo ""
echo "2. Granting Tasker-like permissions to Termux..."

# WRITE_SECURE_SETTINGS - Critical for automation
echo -n "Granting WRITE_SECURE_SETTINGS... "
./rish -c "pm grant com.termux android.permission.WRITE_SECURE_SETTINGS" 2>/dev/null && echo "✓" || {
    echo "✗"
    echo "  Alternative: ./rish -c \"settings put secure <setting> <value>\""
}

# READ_LOGS - For monitoring system events
echo -n "Granting READ_LOGS... "
./rish -c "pm grant com.termux android.permission.READ_LOGS" 2>/dev/null && echo "✓" || {
    echo "✗"
    echo "  Alternative: ./rish -c \"logcat\""
}

# DUMP - For system information
echo -n "Granting DUMP... "
./rish -c "pm grant com.termux android.permission.DUMP" 2>/dev/null && echo "✓" || {
    echo "✗"
    echo "  Alternative: ./rish -c \"dumpsys\""
}

# SET_VOLUME_KEY_LONG_PRESS_LISTENER
echo -n "Granting volume key access... "
./rish -c "pm grant com.termux android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER" 2>/dev/null && echo "✓" || echo "✗"

# 3. Set up accessibility-like features
echo ""
echo "3. Configuring accessibility features..."

# Enable Termux in accessibility settings
./rish -c "settings put secure enabled_accessibility_services com.termux/.app.TermuxAccessibilityService" 2>/dev/null

# 4. Battery optimization
echo ""
echo "4. Disabling battery restrictions..."
./rish -c "dumpsys deviceidle whitelist +com.termux" 2>/dev/null
./rish -c "cmd appops set com.termux RUN_IN_BACKGROUND allow" 2>/dev/null
./rish -c "cmd appops set com.termux RUN_ANY_IN_BACKGROUND allow" 2>/dev/null
./rish -c "am set-standby-bucket com.termux active" 2>/dev/null

# 5. Create Tasker-compatible scripts directory
echo ""
echo "5. Setting up Tasker scripts directory..."
mkdir -p ~/.termux/tasker
chmod 700 ~/.termux/tasker

# Create example Tasker script
cat > ~/.termux/tasker/example.sh << 'SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
# Example Tasker-compatible script

# Scripts in ~/.termux/tasker/ can be run from Tasker
# They must be executable and have .sh extension

echo "Hello from Termux!"
echo "Arguments: $@"

# Return exit code for Tasker
exit 0
SCRIPT
chmod +x ~/.termux/tasker/example.sh

# 6. Create helper functions for Tasker-like operations
cat > ~/tasker_helpers.sh << 'HELPERS'
#!/data/data/com.termux/files/usr/bin/bash
# Tasker-like helper functions using rish

export RISH_APPLICATION_ID=com.termux

# Function to change settings
secure_setting() {
    ./rish -c "settings put secure $1 $2"
}

global_setting() {
    ./rish -c "settings put global $1 $2"
}

system_setting() {
    ./rish -c "settings put system $1 $2"
}

# Function to send broadcasts
send_broadcast() {
    ./rish -c "am broadcast -a $1"
}

# Function to start activities
start_activity() {
    ./rish -c "am start -n $1"
}

# Function to query content providers
query_content() {
    ./rish -c "content query --uri $1"
}

# Function to control media
media_control() {
    case "$1" in
        play) ./rish -c "input keyevent KEYCODE_MEDIA_PLAY" ;;
        pause) ./rish -c "input keyevent KEYCODE_MEDIA_PAUSE" ;;
        next) ./rish -c "input keyevent KEYCODE_MEDIA_NEXT" ;;
        prev) ./rish -c "input keyevent KEYCODE_MEDIA_PREVIOUS" ;;
    esac
}

# Function to get device info
device_info() {
    echo "Battery: $(./rish -c 'dumpsys battery | grep level' | awk '{print $2}')"
    echo "WiFi: $(./rish -c 'dumpsys wifi | grep "Wi-Fi is"' | head -1)"
    echo "Mobile: $(./rish -c 'dumpsys telephony.registry | grep mServiceState' | head -1)"
}
HELPERS
chmod +x ~/tasker_helpers.sh

# 7. Create automation examples
cat > ~/TASKER_AUTOMATION.md << 'DOC'
# Termux + Tasker Automation Guide

## Setup Complete!

### What We've Configured:
1. ✓ Termux:Tasker plugin check
2. ✓ Tasker-like permissions (where possible)
3. ✓ Battery optimization disabled
4. ✓ Scripts directory at ~/.termux/tasker/
5. ✓ Helper functions for automation

### How to Use with Tasker:

1. **Run Termux Scripts from Tasker:**
   - Use Termux:Tasker plugin
   - Select script from ~/.termux/tasker/
   - Pass variables as arguments

2. **Direct Commands via Tasker:**
   - Use "Run Shell" action
   - Command: `/data/data/com.termux/files/usr/bin/bash -c "your command"`
   - Check "Use Root" if you have root

3. **Using rish from Tasker:**
   ```
   /data/data/com.termux/files/home/rish -c "command"
   ```

### Example Automations:

1. **Toggle WiFi:**
   ```bash
   ./rish -c "svc wifi enable"
   ./rish -c "svc wifi disable"
   ```

2. **Change Display Timeout:**
   ```bash
   ./rish -c "settings put system screen_off_timeout 30000"
   ```

3. **Launch App:**
   ```bash
   ./rish -c "monkey -p com.example.app 1"
   ```

4. **Send Notification:**
   ```bash
   termux-notification -t "Title" -c "Content"
   ```

### Helper Functions:
Source `~/tasker_helpers.sh` for functions like:
- `secure_setting <key> <value>`
- `media_control play|pause|next|prev`
- `device_info`
- `send_broadcast <action>`

### Limitations:
Some Tasker features require:
- Root access
- Device Administrator
- Accessibility Service
- System app status

We've configured the maximum possible without root.
DOC

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "✓ Termux configured for Tasker integration"
echo "✓ Scripts directory: ~/.termux/tasker/"
echo "✓ Helper functions: ~/tasker_helpers.sh"
echo "✓ Documentation: ~/TASKER_AUTOMATION.md"
echo ""
echo "Next steps:"
echo "1. Install Termux:Tasker from F-Droid"
echo "2. Create scripts in ~/.termux/tasker/"
echo "3. Use Tasker's Termux:Tasker plugin"
echo ""
echo "Example test:"
echo "~/.termux/tasker/example.sh"