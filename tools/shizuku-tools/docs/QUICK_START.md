# Quick Start Guide

## 1. Install Shizuku

```bash
# Download Shizuku from Play Store
# Or visit: https://shizuku.rikka.app/
```

## 2. Start Shizuku

### Via Wireless Debugging (Android 11+):
1. Enable Developer Options
2. Enable Wireless Debugging
3. Open Shizuku app
4. Tap "Start via Wireless Debugging"
5. Follow pairing instructions

## 3. Test rish

```bash
# Export rish files from Shizuku app
# Then test:
export RISH_APPLICATION_ID=com.termux
./rish -c "whoami"
# Should output: shell
```

## 4. Use Enhanced Commands

```bash
# Package management
spm list packages -3      # List user apps
spm disable com.example   # Disable app

# System info
sdumpsys battery         # Battery status
ssettings list global    # Global settings

# Activity manager
sam force-stop com.app   # Force stop app
```

## 5. Lucky Patcher Extensions

```bash
# List patchable apps
./lucky-patcher/lp_ultimate.sh list-patchable

# Patch an app
./lucky-patcher/lp_ultimate.sh super-patch com.example.app
```

## 6. AI Tools

```bash
# Setup API keys
./ai-tools/ai setup

# Use AI
ai claude "Hello Claude"
ai gemini "Hello Gemini"
```

## Common Issues

### "Server is not running"
- Restart Shizuku app
- Re-enable Wireless Debugging
- Run: `./shizuku/shizuku_control.sh start`

### "Permission denied"
- Make scripts executable: `chmod +x script.sh`
- Check rish setup: `export RISH_APPLICATION_ID=com.termux`

### "Package not found"
- Verify app is installed: `spm list packages | grep appname`
- Use correct package name (not app name)