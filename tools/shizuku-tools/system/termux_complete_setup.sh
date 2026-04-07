#!/data/data/com.termux/files/usr/bin/bash

echo "=== Complete Termux Setup Script ==="
echo ""

# Update repositories
echo "[1/6] Updating package repositories..."
pkg update -y

# Install essential packages
echo ""
echo "[2/6] Installing essential packages..."
pkg install -y \
    android-tools \
    openssh \
    nmap \
    net-tools \
    curl \
    wget \
    git \
    python \
    nodejs \
    vim \
    tmux \
    htop \
    tree \
    jq \
    ffmpeg \
    imagemagick \
    termux-api \
    termux-services \
    tsu \
    root-repo

# Set up storage access
echo ""
echo "[3/6] Setting up storage permissions..."
termux-setup-storage

# Configure SSH
echo ""
echo "[4/6] Configuring SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key if not exists
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "SSH key generated at ~/.ssh/id_rsa"
fi

# Set up useful aliases
echo ""
echo "[5/6] Setting up aliases..."
cat >> ~/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias adb-wireless='~/setup_wireless_adb.sh'
alias myip='curl -s ifconfig.me'
alias localip='ifconfig 2>/dev/null | grep -A1 wlan0 | grep inet | awk "{print \$2}"'

# ADB shortcuts
alias adbs='adb shell'
alias adbd='adb devices'
alias adbr='adb reboot'
alias adbw='adb tcpip 5555'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Function to quickly connect to wireless ADB
adb-connect() {
    if [ -z "$1" ]; then
        echo "Usage: adb-connect <device-ip>"
        return 1
    fi
    adb connect $1:5555
}

# Function to start SSH server
ssh-start() {
    sshd
    echo "SSH server started on port 8022"
    echo "Connect using: ssh -p 8022 $(whoami)@<device-ip>"
}

# Function to stop SSH server
ssh-stop() {
    pkill sshd
    echo "SSH server stopped"
}

EOF

# Set up Python environment
echo ""
echo "[6/6] Setting up Python environment..."
pip install --upgrade pip
pip install requests beautifulsoup4 pandas numpy matplotlib

# Create useful directories
mkdir -p ~/projects ~/scripts ~/downloads

# Final message
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Useful commands:"
echo "  adb-wireless    - Set up wireless ADB"
echo "  ssh-start       - Start SSH server on port 8022"
echo "  myip            - Show public IP"
echo "  localip         - Show local IP"
echo ""
echo "ADB shortcuts:"
echo "  adbs            - Open ADB shell"
echo "  adbd            - List ADB devices"
echo "  adbw            - Enable wireless ADB"
echo ""
echo "Please restart Termux or run: source ~/.bashrc"