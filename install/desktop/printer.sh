#!/bin/bash

# Install CUPS printing system (skip in containers)
# Check if we're in a container environment
if [ -f /.dockerenv ] || [ -f /run/systemd/container ] || systemd-detect-virt -c &>/dev/null; then
  echo "Skipping printer setup in container environment"
else
  sudo apt install -y --no-install-recommends cups cups-pdf cups-filters system-config-printer
  sudo systemctl enable --now cups.service 2>/dev/null || true
fi
