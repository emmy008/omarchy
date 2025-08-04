#!/bin/bash

# PPA is already added in preflight/packages.sh to ensure all scripts get the latest versions

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

# The PPA provides newer versions of these libraries
# Don't specify version numbers - let apt choose from PPA
sudo apt install -y --no-install-recommends \
  libhyprcursor-dev \
  libhyprutils-dev \
  libhyprlang-dev \
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
  build-essential cmake git golang-go \
  libglib2.0-dev libgtk-4-dev libgtk-layer-shell-dev \
  libvips-dev pkg-config gobject-introspection \
  libgirepository1.0-dev

# Install hyprshot
if ! command -v hyprshot &>/dev/null; then
  cd /tmp
  git clone https://github.com/Gustash/Hyprshot.git
  cd Hyprshot
  # Hyprshot is a bash script, just copy it to /usr/local/bin
  sudo install -Dm755 hyprshot /usr/local/bin/hyprshot
  cd ..
  rm -rf Hyprshot
fi


# Install Walker launcher from source
if ! command -v walker &>/dev/null; then
  cd /tmp
  git clone https://github.com/abenz1267/walker.git
  cd walker
  go build -o walker ./cmd/walker.go
  sudo install -m755 walker /usr/local/bin/
  cd ..
  rm -rf walker
fi

