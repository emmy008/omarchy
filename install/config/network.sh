#!/bin/bash

# Install iwd for wireless management
# iwd is Intel's modern wireless daemon, preferred over wpa_supplicant
if ! command -v iwctl &>/dev/null; then
  sudo apt install -y iwd
  
  # Enable iwd service if systemd is available
  if command -v systemctl &>/dev/null && systemctl list-units &>/dev/null 2>&1; then
    sudo systemctl enable --now iwd.service
  fi
fi

# Fix systemd-networkd-wait-online timeout for multiple interfaces
# Wait for any interface to be online rather than all interfaces
# https://wiki.archlinux.org/title/Systemd-networkd#Multiple_interfaces_that_are_not_connected_all_the_time
sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/wait-for-only-one-interface.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOF
