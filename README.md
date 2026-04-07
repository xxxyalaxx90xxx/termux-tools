# 🔥 Termux Tools Collection

> Bratucha's Ultimate Termux Tool Suite

## 📋 Overview

Collection of powerful shell scripts and Python tools for Termux on Android.

## 🛠️ Tools

### ✍️ Writer Tool v4.0 — GOD MODE
**File:** `.writer.sh`

The ultimate CLI writing & productivity toolkit with **120+ commands** across **29 modules**.

**Features:**
- 📝 Editors (nano, vim)
- 📋 Notes system
- ⚡ 25+ Code Templates (Python, Bash, JS, TS, HTML, CSS, React, Vue, Docker...)
- 🏗️ 10 Project Scaffolds
- 🔧 Text Utilities (wc, regex, case conversion, sort, trim)
- 📝 Markdown Utils (TOC, link checker, stats, HTML export)
- 🤖 AI Assistant (Qwen/Gemini integration)
- 🔍 Advanced File Search
- 📦 Snippet Manager
- 🗜️ Archive Management
- 🔀 Git Integration
- 📋 Clipboard
- 🔐 Password Generator & Manager
- 📊 Data Format Conversion (JSON ↔ YAML ↔ TOML ↔ XML ↔ CSV)
- 📋 Log File Analyzer
- 🔒 File Encryption (AES-256)
- 🌐 HTTP/API Client
- 🗄️ SQLite Database Manager
- ⏰ Cron Job Manager
- 💾 Backup/Restore System
- 🔧 Environment Variable Manager
- 🔑 SSH Key Manager
- 🐳 Docker Helpers
- 📚 Doc Generator
- 📡 Network Utilities
- ⚡ Benchmarking (CPU, Disk, Memory)
- 🎨 Color Themes

**Usage:**
```bash
writer              # Show help
writer template py my_script    # Create template
writer note "My Note"           # Create note
writer ai-write "Prompt"        # AI writing
writer encrypt file.txt         # Encrypt file
writer backup-create ~/dir      # Create backup
```

### 📱 Startpage
**File:** `.startpage.sh`

Beautiful Termux start page with system info and quick commands.

### 🤖 AI Dashboard
**File:** `ai-dashboard.sh`

AI management dashboard for monitoring and controlling AI tools.

### 🌐 AI Hub
**File:** `ai-hub.sh`

Central hub for all AI tools and services.

### 🤖 AI Bot
**File:** `ai-bot.py`

Python-based AI bot for automation tasks.

### 📥 Download Models
**File:** `download-models.sh`

Script for downloading AI models.

### 🎬 Matrix Rain
**File:** `matrix-rain.py`

Classic Matrix rain animation in the terminal.

### 📱 Phone Tune
**File:** `phone-tune.sh`

Phone optimization and tuning script.

### ⚡ Speed Boost
**File:** `speed-boost.sh`

Network and system performance optimization.

### 🔧 T-Setup
**File:** `T-setup.sh`

Complete Termux setup and configuration script.

### 📊 Termux CLI Manager
**File:** `termux_cli_manager.py`

Comprehensive Termux management tool (v9.0) with 76+ commands.

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/termux-tools.git
cd termux-tools

# Install dependencies
pkg install nano vim tree curl openssl sqlite python3 -y

# Setup aliases
echo "alias writer='bash ~/.writer.sh'" >> ~/.zshrc
echo "alias startpage='bash ~/.startpage.sh'" >> ~/.zshrc
source ~/.zshrc

# Copy scripts to home
cp * ~/.
chmod +x ~/.writer.sh ~/.startpage.sh *.sh *.py
```

## 🚀 Quick Start

```bash
# Open startpage
startpage

# Use Writer Tool
writer

# Run AI Dashboard
ai-dash

# Matrix Rain
matrix-rain

# Phone Optimization
phone-tune

# Speed Boost
speed-boost
```

## ⚙️ System Requirements

- **OS:** Android 13+ with Termux
- **Shell:** Zsh or Bash
- **Python:** 3.10+
- **Node.js:** 18+

## 📊 Stats

- **Total Scripts:** 11
- **Total Commands:** 120+
- **Modules:** 29
- **Templates:** 25+
- **Project Types:** 10+

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

MIT License

---

**Made with ❤️ for Termux**
