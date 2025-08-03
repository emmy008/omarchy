#!/bin/bash

# Install gum (TUI toolkit)
if ! command -v gum &>/dev/null; then
  # Add Charm GPG key
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  # Only update for this new repository
  sudo apt update -o Dir::Etc::sourcelist="sources.list.d/charm.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
  sudo apt install -y gum
fi

# Install terminal text effects via pipx
if ! command -v tte &>/dev/null; then
  # Ensure pipx is in PATH
  export PATH="$HOME/.local/bin:$PATH"
  pipx install terminaltexteffects
fi