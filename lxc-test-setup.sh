#!/bin/bash

# LXC/LXD Test Environment Setup Script for Omarchy
# This script prepares an LXD environment for testing Omarchy on Ubuntu

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root. It will use sudo when needed."
fi

log "Starting LXD setup for Omarchy testing..."

# Check if LXD is installed
if ! command -v lxd &> /dev/null; then
    log "LXD not found. Installing LXD..."
    sudo snap install lxd
    
    # Wait for snap to settle
    sleep 5
fi

# Add current user to lxd group if not already
if ! groups | grep -q lxd; then
    log "Adding current user to lxd group..."
    sudo usermod -aG lxd "$USER"
    warning "You've been added to the lxd group. You need to log out and back in for this to take effect."
    warning "After logging back in, run this script again."
    warning "Or run: newgrp lxd"
    exit 0
fi

# Check if LXD is initialized
if ! lxc list &>/dev/null 2>&1; then
    log "Initializing LXD..."
    
    # Create preseed configuration for automated setup
    cat > /tmp/lxd-init-preseed.yaml << EOF
config: {}
networks:
- config:
    ipv4.address: auto
    ipv4.nat: true
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: bridge
storage_pools:
- config:
    size: 20GB
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
EOF

    # Initialize LXD with preseed
    cat /tmp/lxd-init-preseed.yaml | sudo lxd init --preseed
    rm /tmp/lxd-init-preseed.yaml
    
    log "LXD initialized successfully"
fi

# Verify network configuration
log "Verifying network configuration..."
if ! lxc network list | grep -q lxdbr0; then
    log "Creating lxdbr0 network..."
    lxc network create lxdbr0 ipv4.address=auto ipv4.nat=true ipv6.address=none
fi

# Check if lxdbr0 has NAT enabled
if ! lxc network show lxdbr0 | grep -q "ipv4.nat: \"true\""; then
    log "Enabling NAT on lxdbr0..."
    lxc network set lxdbr0 ipv4.nat=true
fi

# Create a custom profile for Omarchy testing
log "Creating Omarchy test profile..."

cat > /tmp/omarchy-test-profile.yaml << EOF
config:
  limits.cpu: "2"
  limits.memory: 2GB
  security.nesting: "true"
  security.syscalls.intercept.mknod: "true"
  security.syscalls.intercept.setxattr: "true"
description: Profile for testing Omarchy installation
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    type: disk
  omarchy-source:
    source: ${PWD}
    path: /omarchy-source
    type: disk
name: omarchy-test
EOF

# Create or update the profile
if lxc profile list | grep -q omarchy-test; then
    log "Updating existing omarchy-test profile..."
    lxc profile edit omarchy-test < /tmp/omarchy-test-profile.yaml
else
    log "Creating omarchy-test profile..."
    lxc profile create omarchy-test
    lxc profile edit omarchy-test < /tmp/omarchy-test-profile.yaml
fi

rm /tmp/omarchy-test-profile.yaml

# Check available Ubuntu images
log "Checking available Ubuntu images..."

# Try to find Ubuntu 25.04 first, fall back to 24.04
UBUNTU_VERSION=""
# Check if Ubuntu 25.04 is available
if lxc image list ubuntu:25.04 &>/dev/null; then
    UBUNTU_VERSION="25.04"
    info "Ubuntu 25.04 image found"
elif lxc image list ubuntu:24.04 &>/dev/null; then
    UBUNTU_VERSION="24.04"
    warning "Ubuntu 25.04 not found, using Ubuntu 24.04 LTS instead"
else
    error "No suitable Ubuntu image found. Please check your LXD installation."
fi

# Create test container if it doesn't exist
CONTAINER_NAME="omarchy-test-ubuntu"

if lxc list | grep -q "$CONTAINER_NAME"; then
    warning "Container '$CONTAINER_NAME' already exists."
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Deleting existing container..."
        lxc delete --force "$CONTAINER_NAME"
    else
        info "Keeping existing container. You can start testing with ./run-lxc-test.sh"
        exit 0
    fi
fi

log "Creating test container '$CONTAINER_NAME' with Ubuntu $UBUNTU_VERSION..."
lxc launch "ubuntu:$UBUNTU_VERSION" "$CONTAINER_NAME" --profile default --profile omarchy-test

# Wait for container to be ready
log "Waiting for container to be ready..."
# Wait until the container is running
while [ "$(lxc info "$CONTAINER_NAME" | grep -E "^Status:" | awk '{print $2}')" != "RUNNING" ]; do
    sleep 1
done
log "Container is running"

# Wait for systemd to be ready
log "Waiting for systemd to initialize..."
lxc exec "$CONTAINER_NAME" -- bash -c 'while ! systemctl is-system-running &>/dev/null; do sleep 1; done' || true

# Wait for cloud-init to complete
log "Waiting for cloud-init to complete in container..."
lxc exec "$CONTAINER_NAME" -- cloud-init status --wait || true

# Test network connectivity
log "Testing network connectivity..."
if ! lxc exec "$CONTAINER_NAME" -- ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
    warning "No internet connectivity detected in container"
    log "Attempting to fix network configuration..."
    
    # Restart networking in container
    lxc exec "$CONTAINER_NAME" -- systemctl restart systemd-networkd || true
    lxc exec "$CONTAINER_NAME" -- systemctl restart systemd-resolved || true
    
    # Wait a bit for network to come up
    sleep 5
    
    # Test again
    if ! lxc exec "$CONTAINER_NAME" -- ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
        error "Container has no internet connectivity. Please check your LXD network configuration."
    fi
fi
log "Network connectivity confirmed"

# Update container
log "Updating container packages..."
lxc exec "$CONTAINER_NAME" -- apt update
lxc exec "$CONTAINER_NAME" -- apt upgrade -y

# Install basic dependencies
log "Installing basic dependencies in container..."
lxc exec "$CONTAINER_NAME" -- apt install -y sudo git curl wget

# Create test user
log "Creating test user in container..."
lxc exec "$CONTAINER_NAME" -- useradd -m -s /bin/bash -G sudo testuser
lxc exec "$CONTAINER_NAME" -- bash -c "echo 'testuser:testpass' | chpasswd"
lxc exec "$CONTAINER_NAME" -- bash -c "echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

# Create test results directory
log "Setting up test environment..."
lxc exec "$CONTAINER_NAME" -- mkdir -p /test-results
lxc exec "$CONTAINER_NAME" -- chown testuser:testuser /test-results

# Create a snapshot for easy reset
log "Creating snapshot 'fresh' for easy reset..."
lxc snapshot "$CONTAINER_NAME" fresh

log "LXD test environment setup complete!"
echo
info "Container Details:"
info "  Name: $CONTAINER_NAME"
info "  Ubuntu Version: $UBUNTU_VERSION"
info "  Profile: omarchy-test"
info "  Resource Limits: 2 CPUs, 2GB RAM"
info "  Omarchy source mounted at: /omarchy-source"
echo
log "To start testing, run: ./run-lxc-test.sh"
log "To reset container to fresh state: lxc restore $CONTAINER_NAME fresh"
log "To access container manually: lxc exec $CONTAINER_NAME -- su - testuser"