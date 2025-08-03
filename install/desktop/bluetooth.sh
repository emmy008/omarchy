#!/bin/bash

# Install bluetooth controls
# Blueberry is a GTK+ Bluetooth manager
sudo apt install -y blueman bluez

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
