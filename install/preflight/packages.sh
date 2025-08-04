#!/bin/bash

# Set up essential tools, PPAs and package managers for Ubuntu
# This includes tools for building packages and installing from various sources

# Update package lists (only if not already done)
if [[ -z "$OMARCHY_APT_UPDATED" ]]; then
  sudo apt update
  export OMARCHY_APT_UPDATED=1
fi

# Install essential build tools
sudo apt install -y build-essential cmake pkg-config git curl wget software-properties-common

# Add universe repository if not already enabled
sudo add-apt-repository -y universe

# Install tools for adding PPAs
sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release

# Add Hyprland PPA early to ensure we get the latest versions throughout installation
# This prevents conflicts with older Ubuntu packages
echo "Adding Hyprland PPA for latest packages..."
if ! grep -q "cppiber/hyprland" /etc/apt/sources.list.d/*.list 2>/dev/null; then
  sudo add-apt-repository -y ppa:cppiber/hyprland
  sudo apt update
fi

# Enable progress bars in apt for better visual feedback
if ! grep -q "Dpkg::Progress-Fancy" /etc/apt/apt.conf.d/99progressbar 2>/dev/null; then
  echo 'Dpkg::Progress-Fancy "1";' | sudo tee /etc/apt/apt.conf.d/99progressbar >/dev/null
fi

# Install cargo for Rust-based tools
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  # Add cargo to current shell
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Install Go for building tools like cliphist
if ! command -v go &>/dev/null; then
  sudo apt install -y golang-go
  # Add Go to current shell
  export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
fi

# Install pipx for Python applications
if ! command -v pipx &>/dev/null; then
  # On newer Ubuntu, pipx is available in apt
  if apt-cache show pipx &>/dev/null; then
    sudo apt install -y pipx
  else
    # For older Ubuntu, install via pip with break-system-packages flag
    sudo apt install -y python3-pip python3-venv python3-full
    python3 -m pip install --user --break-system-packages pipx
    python3 -m pipx ensurepath
  fi
  # Add pipx to current shell
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install snap for some applications not available in apt
if ! command -v snap &>/dev/null; then
  sudo apt install -y snapd
  # Only try to enable systemd services if not in Docker
  if [[ ! -f /.dockerenv ]] && systemctl is-system-running &>/dev/null; then
    sudo systemctl enable --now snapd.socket || true
  fi
fi

# Skip final update since we'll do it once at the end of all installations