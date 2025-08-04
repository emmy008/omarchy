#!/bin/bash

# Install bluetooth controls
# Blueberry is a GTK+ Bluetooth manager
sudo apt install -y --no-install-recommends blueman bluez

# Turn on bluetooth by default (non-critical - may fail in containers)
sudo systemctl enable bluetooth.service 2>/dev/null || true
sudo systemctl start bluetooth.service 2>/dev/null || true
