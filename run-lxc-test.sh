#!/bin/bash

# LXC Test Runner for Omarchy
# This script runs the Omarchy installation test in an LXC container

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log() {
    echo -e "${GREEN}[TEST]${NC} $1"
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

# Configuration
CONTAINER_NAME="omarchy-test-ubuntu"
TEST_USER="testuser"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_OUTPUT_FILE="test-results/lxc-test-output-${TIMESTAMP}.log"

# Check if container exists
if ! lxc list | grep -q "$CONTAINER_NAME"; then
    error "Container '$CONTAINER_NAME' not found. Please run ./lxc-test-setup.sh first"
fi

# Check if container is running
if ! lxc list | grep "$CONTAINER_NAME" | grep -q RUNNING; then
    log "Starting container '$CONTAINER_NAME'..."
    lxc start "$CONTAINER_NAME"
    sleep 5
fi

# Create test results directory if it doesn't exist
mkdir -p test-results

log "Starting Omarchy installation test in LXC container..."
log "Test output will be saved to: $TEST_OUTPUT_FILE"

# Create test script inside container
log "Creating test script in container..."

cat << 'EOF' | lxc exec "$CONTAINER_NAME" -- tee /tmp/omarchy-lxc-test.sh > /dev/null
#!/bin/bash

# Omarchy LXC Installation Test Script
# This runs inside the container

set +e  # Continue on error to capture all issues

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Log functions
log() {
    echo -e "${GREEN}[CONTAINER]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Start testing
log "Starting Omarchy installation test inside LXC container..."
log "Container: $(hostname)"
log "Ubuntu Version: $(lsb_release -d | cut -f2)"
log "Kernel: $(uname -r)"
log "systemd version: $(systemctl --version | head -n1)"
echo

# Test systemd functionality
log "Testing systemd functionality..."
if systemctl is-system-running &>/dev/null; then
    log "✓ systemd is running properly: $(systemctl is-system-running)"
else
    warning "⚠ systemd status: $(systemctl is-system-running 2>&1 || echo 'not running')"
fi

# Copy Omarchy source to home directory
log "Copying Omarchy source to test location..."
cp -r /omarchy-source ~/omarchy
cd ~/omarchy

# Run boot.sh to simulate fresh installation
log "Running boot.sh to start installation..."
if [[ -f boot.sh ]]; then
    bash boot.sh
else
    error "boot.sh not found!"
    exit 1
fi

# Source the environment to get omarchy in PATH
export PATH="$HOME/.local/share/omarchy/bin:$PATH"

# Check if installation completed
if [[ -d "$HOME/.local/share/omarchy" ]]; then
    log "✓ Omarchy installed to ~/.local/share/omarchy"
else
    error "✗ Omarchy installation directory not found"
fi

# Run the main installation
log "Running main installation..."
cd "$HOME/.local/share/omarchy"
bash install.sh

# Test key services that failed in Docker
log "=== Testing System Services ==="

# Test snapd
if command -v snap &>/dev/null; then
    log "✓ snap command found"
    if systemctl is-active --quiet snapd; then
        log "✓ snapd service is running"
        # Try to list snaps
        if snap list &>/dev/null; then
            log "✓ snap is functional"
        else
            warning "⚠ snap list failed"
        fi
    else
        warning "⚠ snapd service not running: $(systemctl status snapd 2>&1 | grep Active || echo 'unknown')"
    fi
else
    warning "⚠ snap not installed"
fi

# Test power-profiles-daemon
if systemctl list-unit-files | grep -q power-profiles-daemon; then
    if systemctl is-active --quiet power-profiles-daemon; then
        log "✓ power-profiles-daemon is running"
        if command -v powerprofilesctl &>/dev/null; then
            log "  Current profile: $(powerprofilesctl get 2>/dev/null || echo 'unknown')"
        fi
    else
        warning "⚠ power-profiles-daemon not running"
    fi
else
    warning "⚠ power-profiles-daemon not installed"
fi

# Update PATH for installed tools
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
source "$HOME/.bashrc" 2>/dev/null || true

# Test all expected commands
log "=== Testing Installed Commands ==="
commands_to_check=(
    "git" "curl" "wget" "gum" "tte" "fd" "bat" "rg"
    "eza" "zoxide" "fastfetch" "cargo" "pipx" "mise"
    "lazygit" "gh" "alacritty" "btop" "impala"
)

successful=0
failed=0

for cmd in "${commands_to_check[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        location=$(which "$cmd")
        log "✓ $cmd found at $location"
        ((successful++))
    else
        warning "✗ $cmd not found"
        ((failed++))
        
        # Check for Ubuntu alternates
        case "$cmd" in
            "fd")
                if command -v "fdfind" &>/dev/null; then
                    info "  → fdfind found at $(which fdfind)"
                fi
                ;;
            "bat")
                if command -v "batcat" &>/dev/null; then
                    info "  → batcat found at $(which batcat)"
                fi
                ;;
        esac
    fi
done

# Test Omarchy commands
log "=== Testing Omarchy Commands ==="
omarchy_commands=(
    "omarchy"
    "omarchy-update"
    "omarchy-migrate"
    "omarchy-theme-install"
    "omarchy-theme-set"
    "omarchy-refresh-config"
)

for cmd in "${omarchy_commands[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        log "✓ $cmd is available"
    else
        warning "✗ $cmd not found"
    fi
done

# Summary
echo
log "=== Installation Test Summary ==="
log "System: Ubuntu $(lsb_release -r | cut -f2) in LXC"
log "systemd: $(systemctl is-system-running 2>/dev/null || echo 'not running')"
log "Commands: $successful successful, $failed failed"
log "Container provides full systemd support unlike Docker"

# Check if we can run omarchy
if command -v omarchy &>/dev/null; then
    log "✓ Omarchy CLI is available and ready to use"
    echo
    log "You can now access the container with:"
    info "  lxc exec $HOSTNAME -- su - testuser"
    info "  Then run: omarchy"
else
    error "✗ Omarchy CLI not found in PATH"
fi

exit 0
EOF

# Make test script executable
lxc exec "$CONTAINER_NAME" -- chmod +x /tmp/omarchy-lxc-test.sh

# Run the test as testuser and capture output
log "Running installation test as user '$TEST_USER'..."
echo "Test started at: $(date)" > "$TEST_OUTPUT_FILE"
echo "Container: $CONTAINER_NAME" >> "$TEST_OUTPUT_FILE"
echo "=================================================================================" >> "$TEST_OUTPUT_FILE"

# Run test and capture output
lxc exec "$CONTAINER_NAME" -- su - "$TEST_USER" -c "/tmp/omarchy-lxc-test.sh" 2>&1 | tee -a "$TEST_OUTPUT_FILE"

# Add timestamp at the end
echo "=================================================================================" >> "$TEST_OUTPUT_FILE"
echo "Test completed at: $(date)" >> "$TEST_OUTPUT_FILE"

# Capture additional system information
log "Capturing system information..."
{
    echo
    echo "=== Additional System Information ==="
    echo "--- Memory Usage ---"
    lxc exec "$CONTAINER_NAME" -- free -h
    echo
    echo "--- Disk Usage ---"
    lxc exec "$CONTAINER_NAME" -- df -h
    echo
    echo "--- Running Services ---"
    lxc exec "$CONTAINER_NAME" -- systemctl list-units --type=service --state=running
    echo
    echo "--- Failed Services ---"
    lxc exec "$CONTAINER_NAME" -- systemctl list-units --type=service --state=failed
} >> "$TEST_OUTPUT_FILE" 2>&1

log "Test completed! Results saved to: $TEST_OUTPUT_FILE"
echo
info "To access the container for manual testing:"
info "  lxc exec $CONTAINER_NAME -- su - $TEST_USER"
echo
info "To view test results:"
info "  less $TEST_OUTPUT_FILE"
echo
info "To reset container to fresh state:"
info "  lxc restore $CONTAINER_NAME fresh"