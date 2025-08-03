#!/bin/bash

# Install terminal tools
# Note: mlocate is replaced by plocate in modern Ubuntu
sudo apt install -y \
  wget curl unzip net-tools \
  fd-find fzf ripgrep bat jq \
  bash-completion plocate whois || \
sudo apt install -y \
  wget curl unzip net-tools \
  fd-find fzf ripgrep bat jq \
  bash-completion whois  # Try without plocate if it fails

# Install eza (modern ls replacement)
if ! command -v eza &>/dev/null; then
  sudo apt install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  # Only update for this new repository
  sudo apt update -o Dir::Etc::sourcelist="sources.list.d/gierens.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  sudo apt install -y eza
fi

# Install zoxide (smart cd)
if ! command -v zoxide &>/dev/null; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install wl-clipboard
sudo apt install -y wl-clipboard

# Install fastfetch
if ! command -v fastfetch &>/dev/null; then
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
  # Only update for this new repository
  sudo apt update -o Dir::Etc::sourcelist="sources.list.d/zhangsongcui3371-ubuntu-fastfetch-*.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  sudo apt install -y fastfetch
fi

# Install btop
if ! command -v btop &>/dev/null; then
  # Try snap first, but fall back to building from source if snap isn't available
  if command -v snap &>/dev/null && snap list &>/dev/null 2>&1; then
    sudo snap install btop
  else
    # Fall back to apt version if available
    sudo apt install -y btop || warning "btop installation failed"
  fi
fi

# Install alacritty
if ! command -v alacritty &>/dev/null; then
  # Try to install from main repos first (available in Ubuntu 23.04+)
  if sudo apt install -y alacritty 2>/dev/null; then
    echo "Alacritty installed from main repository"
  else
    # Fall back to PPA for older Ubuntu versions
    sudo add-apt-repository -y ppa:aslatter/ppa || true
    # Only update for this new repository
    sudo apt update -o Dir::Etc::sourcelist="sources.list.d/aslatter-ubuntu-ppa-*.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" || true
    sudo apt install -y alacritty
  fi
fi

# Install impala (Wi-Fi selector) from source
if ! command -v impala &>/dev/null; then
  # Ensure cargo is in PATH
  export PATH="$HOME/.cargo/bin:$PATH"
  source "$HOME/.cargo/env" 2>/dev/null || true
  cargo install impala
fi

# Create symlinks for fd (Ubuntu installs it as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  sudo mkdir -p /usr/local/bin
  sudo ln -sf $(which fdfind) /usr/local/bin/fd
fi

# Create symlinks for bat (Ubuntu installs it as batcat)
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  sudo mkdir -p /usr/local/bin
  sudo ln -sf $(which batcat) /usr/local/bin/bat
fi

# Create symlink for ripgrep (some Ubuntu versions install it with full name)
if ! command -v rg &>/dev/null; then
  # Check both ripgrep and the actual binary location
  if command -v ripgrep &>/dev/null; then
    sudo mkdir -p /usr/local/bin
    sudo ln -sf $(which ripgrep) /usr/local/bin/rg
  elif [[ -x /usr/bin/rg ]]; then
    # Sometimes it's already installed as rg but not in PATH
    sudo mkdir -p /usr/local/bin
    sudo ln -sf /usr/bin/rg /usr/local/bin/rg
  fi
fi