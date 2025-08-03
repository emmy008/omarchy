#!/bin/bash

if [ -z "$OMARCHY_BARE" ]; then
  # Install available packages from Ubuntu repos
  sudo apt install -y \
    gnome-calculator gnome-keyring \
    libreoffice obs-studio kdenlive \
    xournalpp pinta
  
  # Signal Desktop - requires official repo
  if ! command -v signal-desktop &>/dev/null; then
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
      sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt install -y signal-desktop
    rm signal-desktop-keyring.gpg
  fi
  
  # Spotify - requires snap or official repo
  if ! command -v spotify &>/dev/null; then
    # Try snap first
    if command -v snap &>/dev/null; then
      sudo snap install spotify || echo -e "\e[31mFailed to install Spotify. Continuing without!\e[0m"
    fi
  fi
  
  # Note: These packages need manual installation on Ubuntu:
  # - Obsidian: Download AppImage from https://obsidian.md/
  # - LocalSend: Download from https://localsend.org/
  # - Typora: Download .deb from https://typora.io/
  # - Zoom: Download .deb from https://zoom.us/
  # - 1Password: Download from https://1password.com/downloads/linux/
fi

# Copy over Omarchy applications
source ~/.local/share/omarchy/bin/omarchy-refresh-applications || true
