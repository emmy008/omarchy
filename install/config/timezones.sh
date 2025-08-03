#!/bin/bash

# tzupdate is an AUR package on Arch, but not available on Ubuntu
# Ubuntu users can use timedatectl which is built-in
if command -v pacman &>/dev/null; then
  # Arch Linux - install tzupdate from AUR
  if ! command -v tzupdate &>/dev/null; then
    if command -v yay &>/dev/null; then
      yay -S --noconfirm --needed tzupdate
    fi
    sudo tee /etc/sudoers.d/omarchy-tzupdate >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
    sudo chmod 0440 /etc/sudoers.d/omarchy-tzupdate
  fi
elif command -v apt &>/dev/null; then
  # Ubuntu/Debian - timedatectl is already installed with systemd
  # Just set up sudoers for it
  sudo tee /etc/sudoers.d/omarchy-timezone >/dev/null <<EOF
%sudo ALL=(root) NOPASSWD: /usr/bin/timedatectl
EOF
  sudo chmod 0440 /etc/sudoers.d/omarchy-timezone
fi
