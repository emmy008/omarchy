#!/bin/bash

# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.

# Skip power-profiles-daemon in Docker environments
if [[ -f /.dockerenv ]]; then
  echo "Running in Docker - skipping power-profiles-daemon"
  exit 0
fi

sudo apt install -y power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  # Check if power-profiles-daemon is running before trying to set profile
  if systemctl is-active --quiet power-profiles-daemon; then
    powerprofilesctl set balanced || true
  fi

  # Enable battery monitoring timer for low battery notifications
  if [[ -f "$HOME/.config/systemd/user/omarchy-battery-monitor.timer" ]]; then
    systemctl --user enable --now omarchy-battery-monitor.timer || true
  fi
else
  # This computer runs on power outlet
  # Check if power-profiles-daemon is running before trying to set profile
  if systemctl is-active --quiet power-profiles-daemon; then
    powerprofilesctl set performance || true
  fi
fi
