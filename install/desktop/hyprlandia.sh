#!/bin/bash

# Add PPA for latest Hyprland packages
echo "Adding Hyprland PPA for latest packages..."
if ! grep -q "cppiber/hyprland" /etc/apt/sources.list.d/*.list 2>/dev/null; then
  sudo add-apt-repository -y ppa:cppiber/hyprland
  sudo apt update
fi

# Fix any broken packages and prefer PPA versions
echo "Fixing any broken packages..."
# Remove conflicting Ubuntu version if PPA version is installed
if dpkg -l | grep -q libhyprcursor1; then
  sudo apt remove -y libhyprcursor0 2>/dev/null || true
fi
sudo apt --fix-broken install -y || true

# Install Hyprland and all available components from PPA
echo "Installing Hyprland and components from PPA..."
# Install in smaller groups to better handle dependencies
sudo apt install -y --no-install-recommends \
  hyprland \
  hyprland-backgrounds \
  hyprland-protocols \
  hyprpaper

sudo apt install -y --no-install-recommends \
  hyprlock \
  hypridle \
  hyprpicker

sudo apt install -y --no-install-recommends \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk

# Skip libhyprcursor packages if they cause issues - hyprland will pull in what it needs
sudo apt install -y --no-install-recommends \
  libhyprutils0 libhyprutils-dev \
  libhyprlang2 libhyprlang-dev \
  hyprwayland-scanner || true

sudo apt install -y --no-install-recommends \
  waybar \
  mako-notifier \
  swaybg \
  swayosd \
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

