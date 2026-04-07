# Termux Shizuku Tools 🚀

A comprehensive collection of tools and scripts for Termux with Shizuku/rish integration on Android 16+.

## 📋 Features

- **Shizuku Integration** - Full rish support for elevated privileges without root
- **Wireless ADB** - Easy wireless debugging setup
- **Lucky Patcher Extensions** - Advanced app patching capabilities
- **AI CLI Tools** - Claude and Gemini integration
- **System Tools** - Enhanced package management and system control
- **Metasploit Framework** - Security testing tools
- **Android 16 Support** - Fixes and workarounds for latest Android

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/termux-shizuku-tools.git
cd termux-shizuku-tools

# Run the setup script
chmod +x setup.sh
./setup.sh
```

## 📦 Included Tools

### 1. Shizuku/rish Setup
- `shizuku/` - Shizuku integration scripts
- `rish` - Pre-configured rish binary
- Android 14+ SAF workarounds

### 2. Lucky Patcher Extensions
- `lucky-patcher/lp_ultimate.sh` - Ultimate patching functions
- `lucky-patcher/lp_advanced.sh` - Advanced app modifications
- `lucky-patcher/lp_analyze.sh` - App component analyzer

### 3. AI CLI Tools
- `ai-tools/claude_cli.py` - Claude AI integration
- `ai-tools/gemini_cli.py` - Gemini AI integration
- `ai-tools/ai` - Universal AI CLI wrapper

### 4. System Tools
- `system/grant_termux_privileges.sh` - Enhanced permissions
- `system/termux_tasker.sh` - Tasker integration
- `system/wireless_adb.sh` - Wireless ADB setup

### 5. Security Tools
- `security/metasploit/` - Metasploit Framework setup
- Network scanning utilities

## 🚀 Quick Start

### Enable Shizuku
```bash
./shizuku/shizuku_control.sh start
./shizuku/shizuku_control.sh status
```

### Use rish Commands
```bash
# Package management
spm list packages -3
spm disable com.example.app

# System control
sam force-stop com.example.app
sdumpsys battery
```

### Lucky Patcher Extensions
```bash
# List patchable apps
./lucky-patcher/lp_ultimate.sh list-patchable

# Patch an app
./lucky-patcher/lp_ultimate.sh super-patch com.example.app
```

### AI Tools
```bash
# Setup API keys
./ai-tools/ai setup

# Use AI assistants
ai claude "Write a Python script"
ai gemini "Explain quantum computing"
```

## 📱 Requirements

- Android 7.0+ (Android 16 recommended)
- Termux (F-Droid version)
- Shizuku v13.5+
- 300MB+ free storage

## 🔧 Configuration

### API Keys
Store your API keys in `~/.ai_keys`:
```bash
export ANTHROPIC_API_KEY='your-key'
export GOOGLE_AI_API_KEY='your-key'
```

### Shizuku Setup
1. Install Shizuku from Play Store
2. Start via Wireless Debugging
3. Run `./shizuku/setup_shizuku.sh`

## 📚 Documentation

- [Shizuku Guide](docs/SHIZUKU_GUIDE.md)
- [Lucky Patcher Extensions](docs/LUCKY_PATCHER.md)
- [AI Tools Usage](docs/AI_TOOLS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## ⚠️ Legal Notice

These tools are for educational and testing purposes only. Users are responsible for complying with all applicable laws and regulations. Do not use these tools on apps or systems you don't own or have permission to test.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Credits

- Shizuku by RikkaApps
- Termux development team
- All contributors

---

**Note**: This repository is not affiliated with Lucky Patcher, Shizuku, or any mentioned apps.