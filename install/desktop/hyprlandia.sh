#!/bin/bash

# Add PPA for latest Hyprland packages
echo "Adding Hyprland PPA for latest packages..."
if ! grep -q "cppiber/hyprland" /etc/apt/sources.list.d/*.list 2>/dev/null; then
  sudo add-apt-repository -y ppa:cppiber/hyprland
  sudo apt update
fi

# Install Hyprland and all available components from PPA
echo "Installing Hyprland and components from PPA..."
sudo apt install -y --no-install-recommends \
  hyprland \
  hyprland-backgrounds \
  hyprland-protocols \
  hyprpaper \
  hyprlock \
  hypridle \
  hyprpicker \
  xdg-desktop-portal-hyprland \
  libhyprcursor0 libhyprcursor-dev \
  libhyprutils0 libhyprutils-dev \
  libhyprlang2 libhyprlang-dev \
  hyprwayland-scanner \
  waybar \
  mako-notifier \
  swaybg \
  swayosd \
  xdg-desktop-portal-gtk \
  policykit-1-gnome \
  libqalculate-dev qalc

# Install build dependencies for remaining tools (Walker, hyprshot)
sudo apt install -y --no-install-recommends \
  build-essential cmake git golang-go

# Install hyprshot
if ! command -v hyprshot &>/dev/null; then
  cd /tmp
  git clone https://github.com/Gustash/Hyprshot.git
  cd Hyprshot
  sudo make install
  cd ..
  rm -rf Hyprshot
fi


# Install Walker launcher from source
if ! command -v walker &>/dev/null; then
  cd /tmp
  git clone https://github.com/abenz1267/walker.git
  cd walker
  go build -o walker cmd/walker/main.go
  sudo install -m755 walker /usr/local/bin/
  cd ..
  rm -rf walker
fi

