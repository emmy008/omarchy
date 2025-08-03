#!/bin/bash

# Hyprland is not in Ubuntu's official repos, so we need to build from source or use a PPA
# First, install dependencies
sudo apt install -y \
  meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base \
  libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev \
  libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev \
  libvulkan-volk-dev vulkan-utility-libraries-dev libvkfft-dev libgulkan-dev libegl-dev \
  libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev \
  libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev \
  libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev \
  libxcb-xinput-dev xdg-desktop-portal-wlr libtomlplusplus3 \
  hwdata libgbm-dev libnotify-bin zenity polkit-kde-agent-1

# Install Wayland protocols
sudo apt install -y wayland-protocols libwayland-dev

# Build and install Hyprland
if ! command -v Hyprland &>/dev/null; then
  cd /tmp
  git clone --recursive https://github.com/hyprwm/Hyprland
  cd Hyprland
  make all
  sudo make install
  cd ..
  rm -rf Hyprland
fi

# Install hyprlang
if ! pkg-config --exists hyprlang; then
  cd /tmp
  git clone https://github.com/hyprwm/hyprlang.git
  cd hyprlang
  cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  cd ..
  rm -rf hyprlang
fi

# Install hyprpicker
if ! command -v hyprpicker &>/dev/null; then
  cd /tmp
  git clone https://github.com/hyprwm/hyprpicker.git
  cd hyprpicker
  cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  cd ..
  rm -rf hyprpicker
fi

# Install hyprlock
if ! command -v hyprlock &>/dev/null; then
  cd /tmp
  git clone https://github.com/hyprwm/hyprlock.git
  cd hyprlock
  cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  cd ..
  rm -rf hyprlock
fi

# Install hypridle
if ! command -v hypridle &>/dev/null; then
  cd /tmp
  git clone https://github.com/hyprwm/hypridle.git
  cd hypridle
  cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  cd ..
  rm -rf hypridle
fi

# Install hyprshot
if ! command -v hyprshot &>/dev/null; then
  cd /tmp
  git clone https://github.com/Gustash/Hyprshot.git
  cd Hyprshot
  sudo make install
  cd ..
  rm -rf Hyprshot
fi

# Install waybar
sudo apt install -y waybar

# Install mako (notification daemon)
sudo apt install -y mako-notifier

# Install swaybg (wallpaper utility)
sudo apt install -y swaybg

# Install swayosd from source
if ! command -v swayosd-server &>/dev/null; then
  cd /tmp
  git clone https://github.com/ErikReider/SwayOSD.git
  cd SwayOSD
  meson setup build
  ninja -C build
  sudo meson install -C build
  cd ..
  rm -rf SwayOSD
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

# Install libqalculate for calculator support in Walker
sudo apt install -y libqalculate-dev qalc

# Install XDG desktop portals
sudo apt install -y xdg-desktop-portal-gtk

# Build xdg-desktop-portal-hyprland
if ! pkg-config --exists xdg-desktop-portal-hyprland; then
  cd /tmp
  git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
  cd xdg-desktop-portal-hyprland
  cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  cd ..
  rm -rf xdg-desktop-portal-hyprland
fi

# Install polkit-gnome
sudo apt install -y policykit-1-gnome