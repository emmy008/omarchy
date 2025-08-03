#!/bin/bash

# Install CUPS printing system
sudo apt install -y --no-install-recommends cups cups-pdf cups-filters system-config-printer
sudo systemctl enable --now cups.service
