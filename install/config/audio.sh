#!/bin/bash

# Configure PipeWire audio for Ubuntu
echo "Configuring PipeWire audio system..."

# Install PipeWire and related packages
sudo apt install -y \
  pipewire \
  pipewire-pulse \
  pipewire-audio-client-libraries \
  pipewire-audio \
  wireplumber \
  libspa-0.2-bluetooth \
  libspa-0.2-jack

# Disable PulseAudio if it's running
if systemctl --user is-active pulseaudio &>/dev/null; then
  systemctl --user stop pulseaudio
  systemctl --user disable pulseaudio
fi

# Enable PipeWire services
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

# Verify PipeWire is working
if pactl info | grep -q "PipeWire"; then
  echo "PipeWire audio configured successfully"
else
  echo "Warning: PipeWire might not be running correctly"
fi