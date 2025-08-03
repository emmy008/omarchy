#!/bin/bash

# ==============================================================================
# NVIDIA Setup Script for Ubuntu
# ==============================================================================

# --- GPU Detection ---
if [ -n "$(lspci | grep -i 'nvidia')" ]; then
  echo "NVIDIA GPU detected, installing drivers..."

  # Install Ubuntu's NVIDIA driver tools
  sudo apt install -y ubuntu-drivers-common
  
  # Auto-install recommended drivers
  sudo ubuntu-drivers autoinstall
  
  # Install NVIDIA utilities and libraries
  sudo apt install -y \
    nvidia-settings \
    nvidia-utils-535 \
    libnvidia-gl-535 \
    nvidia-cuda-toolkit \
    nvidia-prime
  
  # Install Wayland support for NVIDIA
  sudo apt install -y \
    libnvidia-egl-wayland1 \
    xwayland
  
  # Enable NVIDIA services
  if command -v systemctl &>/dev/null; then
    sudo systemctl enable nvidia-persistenced
  fi
  
  # Configure modprobe for NVIDIA DRM
  echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
  
  # Update initramfs to include NVIDIA modules
  sudo update-initramfs -u
  
  # Add NVIDIA environment variables to Hyprland config
  HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
  if [ -f "$HYPRLAND_CONF" ]; then
    # Check if NVIDIA env vars already exist
    if ! grep -q "NVD_BACKEND" "$HYPRLAND_CONF"; then
      cat >>"$HYPRLAND_CONF" <<'EOF'

# NVIDIA environment variables
env = NVD_BACKEND,direct
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __NV_PRIME_RENDER_OFFLOAD,1
env = WLR_NO_HARDWARE_CURSORS,1
EOF
    fi
  fi
  
  echo "NVIDIA drivers installed. You may need to reboot."
  echo "To switch between Intel/NVIDIA, use: sudo prime-select nvidia|intel|on-demand"
else
  echo "No NVIDIA GPU detected, skipping NVIDIA setup"
fi