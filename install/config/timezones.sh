#!/bin/bash

# Ubuntu uses timedatectl which is built-in with systemd
# Set up sudoers for timezone management
sudo tee /etc/sudoers.d/omarchy-timezone >/dev/null <<EOF
%sudo ALL=(root) NOPASSWD: /usr/bin/timedatectl
EOF
sudo chmod 0440 /etc/sudoers.d/omarchy-timezone
