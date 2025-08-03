#!/bin/bash

# Install fonts
sudo apt install -y --no-install-recommends \
  fonts-font-awesome \
  fonts-noto \
  fonts-noto-color-emoji

# Install Cascadia Code (Microsoft's font)
if ! fc-list | grep -qi "Cascadia"; then
  wget -q https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -O /tmp/cascadia.zip
  sudo unzip -q /tmp/cascadia.zip -d /usr/share/fonts/truetype/
  rm /tmp/cascadia.zip
  sudo fc-cache -f
fi

if [ -z "$OMARCHY_BARE" ]; then
  # Install JetBrains Mono
  sudo apt install -y --no-install-recommends fonts-jetbrains-mono
  
  # Install CJK and extra Noto fonts
  sudo apt install -y --no-install-recommends fonts-noto-cjk fonts-noto-extra
fi

# Note: iA Writer fonts are proprietary and not in Ubuntu repos
# Users need to manually download from https://github.com/iaolo/iA-Fonts if needed
