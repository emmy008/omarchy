#!/bin/bash

# ==============================================================================
# PLYMOUTH SETUP FOR UBUNTU
# ==============================================================================

# Check if Plymouth is installed
if ! command -v plymouth &>/dev/null; then
  echo "Installing Plymouth..."
  sudo apt install -y plymouth plymouth-themes
fi

# Update initramfs for Plymouth (Ubuntu equivalent of mkinitcpio)
if [ -f /etc/default/grub ] && ! grep -q "splash" /etc/default/grub 2>/dev/null; then
  echo "Configuring Plymouth splash screen..."
  
  # Backup GRUB config before modifying
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/default/grub "/etc/default/grub.bak.${backup_timestamp}"
  
  # Add splash and quiet to GRUB
  current_cmdline=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | cut -d'"' -f2)
  new_cmdline="$current_cmdline"
  
  if [[ ! "$current_cmdline" =~ splash ]]; then
    new_cmdline="$new_cmdline splash"
  fi
  if [[ ! "$current_cmdline" =~ quiet ]]; then
    new_cmdline="$new_cmdline quiet"
  fi
  
  # Trim any leading/trailing spaces
  new_cmdline=$(echo "$new_cmdline" | xargs)
  
  sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$new_cmdline\"/" /etc/default/grub
  
  # Update GRUB
  sudo update-grub
  
  # Update initramfs
  sudo update-initramfs -u
elif [ ! -f /etc/default/grub ]; then
  echo "GRUB not installed (container/VM environment) - skipping Plymouth GRUB configuration"
fi

# Set Omarchy Plymouth theme if available
if [ -d "$HOME/.local/share/omarchy/default/plymouth" ]; then
  if [ "$(plymouth-set-default-theme 2>/dev/null)" != "omarchy" ]; then
    sudo cp -r "$HOME/.local/share/omarchy/default/plymouth" /usr/share/plymouth/themes/omarchy/
    sudo plymouth-set-default-theme omarchy
    sudo update-initramfs -u
  fi
fi

# ==============================================================================
# AUTO-LOGIN CONFIGURATION FOR UBUNTU
# ==============================================================================

# Configure GDM for auto-login if desired
if command -v gdm3 &>/dev/null; then
  echo "GDM detected. To enable auto-login:"
  echo "  1. Edit /etc/gdm3/custom.conf"
  echo "  2. Under [daemon] section, add:"
  echo "     AutomaticLoginEnable=true"
  echo "     AutomaticLogin=$USER"
  echo ""
  echo "Or configure via Settings > Users > Automatic Login"
fi

# Configure LightDM for auto-login if desired
if command -v lightdm &>/dev/null; then
  echo "LightDM detected. To enable auto-login:"
  echo "  1. Edit /etc/lightdm/lightdm.conf"
  echo "  2. Under [Seat:*] section, add:"
  echo "     autologin-user=$USER"
  echo "     autologin-user-timeout=0"
fi

echo "Display manager configuration complete."