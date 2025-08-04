#!/bin/bash

# Hyprland is not in Ubuntu's official repos, so we need to build from source or use a PPA
# First, install dependencies
sudo apt install -y --no-install-recommends \
  meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base \
  libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev \
  libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev \
  libvulkan-volk-dev vulkan-utility-libraries-dev libvkfft-dev libgulkan-dev libegl-dev \
  libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev \
  libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev \
  libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev \
  libxcb-xinput-dev libxcb-errors-dev xdg-desktop-portal-wlr libtomlplusplus3 libtomlplusplus-dev \
  hwdata libgbm-dev libnotify-bin zenity polkit-kde-agent-1 libpugixml-dev \
  libre2-dev

# Install Wayland protocols and Hyprland ecosystem dependencies  
# Note: libhyprutils-dev in Ubuntu 25.04 is too old (0.1.5), aquamarine needs >=0.8.0
sudo apt install -y --no-install-recommends wayland-protocols libwayland-dev \
  libdisplay-info-dev hyprwayland-scanner \
  libhyprlang-dev libhyprcursor-dev clang libmagic-dev \
  libpango1.0-dev libpangocairo-1.0-0 libxcursor-dev

# Build newer wayland-protocols (Ubuntu has 1.41, need >=1.43)
if ! pkg-config --exists "wayland-protocols >= 1.43" 2>/dev/null; then
  echo "Building wayland-protocols from source (need >=1.43)..."
  cd /tmp
  rm -rf wayland-protocols
  git clone --depth 1 --branch 1.45 https://gitlab.freedesktop.org/wayland/wayland-protocols.git
  cd wayland-protocols
  meson setup build --prefix=/usr --buildtype=release
  ninja -C build
  sudo ninja -C build install
  # Update pkg-config cache
  sudo ldconfig
  cd ..
  rm -rf wayland-protocols
fi

# Build newer libinput (Ubuntu has 1.27.1, need >=1.28)
if ! pkg-config --exists "libinput >= 1.28" 2>/dev/null; then
  echo "Building libinput from source (need >=1.28)..."
  # Install libinput build dependencies
  sudo apt install -y --no-install-recommends \
    libmtdev-dev libudev-dev libevdev-dev libwacom-dev \
    libgtk-3-dev check
  
  cd /tmp
  rm -rf libinput
  git clone https://gitlab.freedesktop.org/libinput/libinput.git
  cd libinput
  git checkout 1.28.0  # Use specific version
  meson setup build --prefix=/usr
  ninja -C build
  sudo ninja -C build install
  sudo ldconfig
  cd ..
  rm -rf libinput
fi

# Build and install hyprutils (Ubuntu's version is too old for aquamarine)
# First remove any old version from apt if installed
if dpkg -l | grep -q libhyprutils-dev; then
  echo "Removing old hyprutils from apt..."
  sudo apt remove -y libhyprutils-dev libhyprutils0
fi

if ! pkg-config --exists "hyprutils >= 0.8.0" 2>/dev/null; then
  echo "Building hyprutils from source (need >=0.8.0)..."
  cd /tmp
  rm -rf hyprutils  # Clean any previous attempts
  git clone https://github.com/hyprwm/hyprutils.git
  cd hyprutils
  cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  
  # Update pkg-config cache
  sudo ldconfig
  
  # Verify installation
  if pkg-config --exists hyprutils; then
    echo "hyprutils installed successfully (version: $(pkg-config --modversion hyprutils))"
  else
    echo "WARNING: hyprutils installation may have failed"
  fi
  
  cd ..
  rm -rf hyprutils
fi

# Build and install aquamarine (Hyprland's Wayland backend)
# Use clang to avoid zero-size array errors with GCC 14+
if ! pkg-config --exists aquamarine; then
  echo "Building aquamarine with clang..."
  cd /tmp
  git clone https://github.com/hyprwm/aquamarine.git
  cd aquamarine
  CC=clang CXX=clang++ cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  sudo ldconfig
  cd ..
  rm -rf aquamarine
fi

# Build and install hyprgraphics (Hyprland graphics library)
if ! pkg-config --exists "hyprgraphics >= 0.1.3" 2>/dev/null; then
  echo "Building hyprgraphics..."
  cd /tmp
  git clone https://github.com/hyprwm/hyprgraphics.git
  cd hyprgraphics
  cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  cmake --build build
  sudo cmake --install build
  sudo ldconfig
  cd ..
  rm -rf hyprgraphics
fi

# Build and install Hyprland
# Fix string_view issue and use clang
if ! command -v Hyprland &>/dev/null; then
  cd /tmp
  rm -rf Hyprland  # Clean any previous attempts
  git clone --recursive https://github.com/hyprwm/Hyprland
  cd Hyprland
  
  # Fix the string_view concatenation issue in hyprctl/main.cpp
  # Need to convert both instanceSignature and filename to std::string
  sed -i 's/getRuntimeDir() + "\/" + instanceSignature + "\/" + filename/getRuntimeDir() + "\/" + std::string(instanceSignature) + "\/" + std::string(filename)/' hyprctl/main.cpp
  
  CC=clang CXX=clang++ make all
  sudo make install
  cd ..
  rm -rf Hyprland
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
sudo apt install -y --no-install-recommends waybar

# Install mako (notification daemon)
sudo apt install -y --no-install-recommends mako-notifier

# Install swaybg (wallpaper utility)
sudo apt install -y --no-install-recommends swaybg

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
sudo apt install -y --no-install-recommends libqalculate-dev qalc

# Install XDG desktop portals
sudo apt install -y --no-install-recommends xdg-desktop-portal-gtk

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
sudo apt install -y --no-install-recommends policykit-1-gnome