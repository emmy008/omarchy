#!/bin/bash

# Install development tools
sudo apt install -y \
  clang llvm \
  imagemagick \
  libmariadb-dev libpq-dev

# Install GitHub CLI (gh)
if ! command -v gh &>/dev/null; then
  # Add GitHub CLI repository
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update -o Dir::Etc::sourcelist="sources.list.d/github-cli.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  sudo apt install -y gh
fi

# Install mise (formerly rtx) for runtime management
if ! command -v mise &>/dev/null; then
  curl https://mise.jdx.dev/install.sh | sh
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  # Make it available immediately
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install lazygit
if ! command -v lazygit &>/dev/null; then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit.tar.gz lazygit
fi

# Install lazydocker
if ! command -v lazydocker &>/dev/null; then
  curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# Cargo should already be installed from preflight
source "$HOME/.cargo/env" 2>/dev/null || true
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"