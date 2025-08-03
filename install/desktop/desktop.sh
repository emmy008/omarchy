#!/bin/bash

# Install desktop utilities
sudo apt install -y \
  brightnessctl playerctl wireplumber pipewire-audio \
  fcitx5 fcitx5-frontend-gtk3 fcitx5-frontend-qt5 \
  nautilus gnome-sushi ffmpegthumbnailer \
  slurp grim wl-clipboard \
  mpv evince \
  chromium-browser

# Install cliphist for clipboard history (not in Ubuntu repos, build from source)
if ! command -v cliphist &>/dev/null; then
  go install go.senan.xyz/cliphist@latest 2>/dev/null || \
    echo "Note: cliphist not installed, clipboard history won't persist"
fi

# Note: Some packages need alternatives or building from source on Ubuntu:
# - pamixer: Not in Ubuntu repos, use pactl instead
# - wiremix: Not available, use pavucontrol or qpwgraph
# - wl-clip-persist: Not in Ubuntu repos, need to build from source
# - satty: Not in Ubuntu repos, use swappy instead
# - imv: Not in Ubuntu repos, use eog (Eye of GNOME) instead

# Install alternative packages
sudo apt install -y \
  pavucontrol \
  swappy \
  eog

# Add screen recorder
# wf-recorder and wl-screenrec not in Ubuntu repos, use OBS Studio instead
sudo apt install -y obs-studio
