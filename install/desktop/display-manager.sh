#!/bin/bash

# Install a display manager for Ubuntu
# Since the complex auto-login setup is Arch-specific, 
# Ubuntu users need a display manager to launch Hyprland

echo "Installing display manager for Hyprland..."

# Option 1: GDM (GNOME Display Manager) - Works well with Wayland
if ! systemctl is-enabled gdm &>/dev/null 2>&1; then
  sudo apt install -y gdm3
  
  # Enable GDM
  sudo systemctl enable gdm
  
  echo "GDM installed. You can select Hyprland from the session menu at login."
fi

# Create a desktop entry for Hyprland if it doesn't exist
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
  sudo mkdir -p /usr/share/wayland-sessions
  sudo tee /usr/share/wayland-sessions/hyprland.desktop <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An independent, highly customizable, dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
Icon=hyprland
Keywords=tiling;wayland;compositor;
Categories=System;
EOF
fi

echo "Display manager setup complete. Reboot and select Hyprland at the login screen."