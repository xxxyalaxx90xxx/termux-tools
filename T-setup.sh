#!/bin/bash
#Developer: Aman Khan
#Github   : https://github.com/ak-alien

RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1m"

function display_banner() {
    echo -e "${CYAN}"
    echo "    ███████╗███████╗████████╗   ██╗   ██╗██████╗"
    echo "    ██╔════╝██╔════╝╚══██╔══╝   ██║   ██║██╔══██╗"
    echo "    ███████╗█████╗     ██║█████╗██║   ██║██████╔╝"
    echo "    ╚════██║██╔══╝     ██║╚════╝██║   ██║██╔═══╝"
    echo "    ███████║███████╗   ██║      ╚██████╔╝██║"
    echo "    ╚══════╝╚══════╝   ╚═╝       ╚═════╝ ╚═╝"
    echo -e "${RESET}"
    echo -e "${CYAN} ==================================================${RESET}"
    echo -e "${CYAN}    Developed by: Aman Khan${RESET}"
    echo -e "${CYAN}    Github: https://github.com/ak-alien${RESET}"
    echo -e "${CYAN}    Telegram: https://t.me/ak_xlien${RESET}"
    echo -e "${CYAN} ==================================================${RESET}"
    echo ""
}

# Function to print each step with color
function print_step() {
    echo -e "${CYAN}[+]${GREEN} $1 ${RESET}"
}

# Function to install a package using pkg
function install_package() {
    pkg install "$1" -y
}

# Function to install a package using pip
function install_pip_package() {
    pip install "$1"
}

# Function to install a package using pip2
function install_pip2_package() {
    pip2 install "$1"
}

# Function to install a package using gem (Ruby)
function install_gem_package() {
    gem install "$1"
}

# Basic Setup Installation (Essential packages only)
function basic_setup() {
    clear
    display_banner
    print_step "INSTALLING BASIC SETUP STARTS IN 3 SEC..."
    sleep 3

    # Update & Upgrade
    print_step "Updating package list..."
    pkg update -y

    print_step "Upgrading packages..."
    pkg upgrade -y

    # Basic Package installations
    print_step "Installing Python..."
    install_package python

    print_step "Installing Git..."
    install_package git

    print_step "Installing Nano..."
    install_package nano

    print_step "Installing Curl..."
    install_package curl

    print_step "Installing OpenSSH..."
    install_package openssh

    clear
    display_banner
    sleep 0.5
    print_step "Basic Setup completed successfully!"
}

# Full Setup Installation (Includes all packages)
function full_setup() {
    clear
    display_banner
    print_step "INSTALLING FULL SETUP STARTS IN 3 SEC..."
    sleep 3

    # Update & Upgrade
    print_step "Updating package list..."
    pkg update -y

    print_step "Upgrading packages..."
    pkg upgrade -y

    # Package installations
    print_step "Installing Python..."
    install_package python

    print_step "Installing Python2..."
    install_package python2

    print_step "Installing Python3..."
    install_package python3

    print_step "Installing Ruby..."
    install_package ruby

    print_step "Installing PHP..."
    install_package php

    print_step "Installing Tmux..."
    install_package tmux

    print_step "Installing Curl..."
    install_package curl

    print_step "Installing Git..."
    install_package git

    print_step "Installing Wget..."
    install_package wget

    print_step "Installing Nano..."
    install_package nano

    print_step "Installing OpenSSH..."
    install_package openssh

    # Pip3 installations
    print_step "Installing Requests for Python3..."
    install_pip_package requests

    print_step "Installing BeautifulSoup4 for Python3..."
    install_pip_package bs4

    print_step "Installing Rich for Python3 (Terminal formatting)..."
    install_pip_package rich

    print_step "Installing Futures for Python3..."
    install_pip_package futures

    print_step "Installing Httpx for Python3..."
    install_pip_package httpx

    print_step "Installing PyCurl for Python3..."
    install_pip_package pycurl

    # Pip2 installations
    print_step "Installing Requests for Python2..."
    install_pip2_package requests

    print_step "Installing Mechanize for Python2..."
    install_pip2_package mechanize

    print_step "Installing BeautifulSoup4 for Python2..."
    install_pip2_package bs4

    # Ruby Gem installation
    print_step "Installing Lolcat (Colorful output via Ruby)..."
    install_gem_package lolcat

    clear
    display_banner
    sleep 0.5
    print_step "Full Setup completed successfully!"
}

function show_menu() {
    clear
    display_banner
    echo "  [1] Basic Setup (575-700 MB)"
    echo "  [2] Full Setup (665-800 MB)"
    echo "  [0] Exit"
    echo ""
    read -p "  [+] Please enter your choice (1-3): " choice

    case $choice in
        1)
            basic_setup
            ;;
        2)
            full_setup
            ;;
        0)
            echo -e "${CYAN}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${CYAN}Invalid option. Please try again.${RESET}"
            show_menu
            ;;
    esac
}

# Checking internet connection
function check_connection() {
    clear
    echo -e "Checking connection..."
    sleep 2
    ping -c 1 -W 0.7 8.8.4.4 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e  "${GREEN}Device Online! ${RESET}"
        sleep 1.5
        show_menu
    else
        echo -e "${RED}Device Offline! ${RESET}"
        echo -e "Please connect to the internet and try again..."
        sleep 1.5
    fi
}

check_connection