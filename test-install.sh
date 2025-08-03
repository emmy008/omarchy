#!/bin/bash

# Don't exit on error - we want to see all issues
set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to update PATH and reload environment
update_environment() {
    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
    
    # Source cargo env if it exists
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
    
    # Source bashrc to get any PATH updates
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
}

# Function to run a script with error handling
run_script() {
    local script="$1"
    local description="$2"
    
    log "Running: $description"
    
    # Run the script and capture exit code
    (
        # Make sure PATH is available
        export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
        source "$script" 2>&1
    )
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log "✓ $description completed successfully"
    else
        warning "⚠ $description had issues (exit code: $exit_code) but continuing..."
    fi
    
    # Always update environment after each script
    update_environment
    
    return 0  # Always return success to continue testing
}

# Start testing
log "Starting Omarchy Ubuntu compatibility test..."
log "Note: Running in Docker environment - some systemd services may fail"

# Initial PATH setup
update_environment

# Run all installation scripts in sequence with proper environment
log "=== Running Installation Scripts ==="

# Preflight
run_script "/home/testuser/.local/share/omarchy/install/preflight/aur.sh" "Package manager setup"
run_script "/home/testuser/.local/share/omarchy/install/preflight/presentation.sh" "Presentation tools"

# Development
run_script "/home/testuser/.local/share/omarchy/install/development/terminal.sh" "Terminal tools"
run_script "/home/testuser/.local/share/omarchy/install/development/development.sh" "Development tools"

# Configuration
run_script "/home/testuser/.local/share/omarchy/install/config/power.sh" "Power management"

# Give tools time to be available in PATH
sleep 2

# Check if key commands are available
log "=== Checking Key Commands ==="
commands_to_check=(
    "git"
    "curl"
    "wget"
    "gum"
    "tte"
    "fd"
    "bat"
    "rg"
    "eza"
    "zoxide"
    "fastfetch"
    "cargo"
    "pipx"
    "mise"
    "lazygit"
    "gh"
    "docker"
    "alacritty"
)

successful_installs=()
failed_commands=()
alternate_found=()

for cmd in "${commands_to_check[@]}"; do
    # Check with updated PATH
    if PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH" command -v "$cmd" &>/dev/null; then
        log "✓ $cmd is installed"
        successful_installs+=("$cmd")
    else
        # Check for Ubuntu alternate names
        case "$cmd" in
            "fd")
                if command -v "fdfind" &>/dev/null; then
                    alternate_found+=("fd → fdfind (symlink may be needed)")
                    warning "fd not found but fdfind exists"
                else
                    failed_commands+=("$cmd")
                    warning "✗ $cmd is not installed"
                fi
                ;;
            "bat")
                if command -v "batcat" &>/dev/null; then
                    alternate_found+=("bat → batcat (symlink may be needed)")
                    warning "bat not found but batcat exists"
                else
                    failed_commands+=("$cmd")
                    warning "✗ $cmd is not installed"
                fi
                ;;
            "rg")
                if command -v "ripgrep" &>/dev/null; then
                    alternate_found+=("rg → ripgrep (symlink may be needed)")
                    warning "rg not found but ripgrep exists"
                else
                    failed_commands+=("$cmd")
                    warning "✗ $cmd is not installed"
                fi
                ;;
            *)
                failed_commands+=("$cmd")
                warning "✗ $cmd is not installed"
                ;;
        esac
    fi
done

# Test package manager functions if the helper script exists
if [[ -f "/home/testuser/.local/share/omarchy/install/lib/package-manager.sh" ]]; then
    log "=== Testing Package Manager Helper ==="
    source "/home/testuser/.local/share/omarchy/install/lib/package-manager.sh"
    
    # Test update function
    if omarchy_update; then
        log "✓ Package update works"
    else
        warning "⚠ Package update had issues"
    fi
fi

# Show detailed PATH information for debugging
log "=== Environment Information ==="
log "Current PATH: $PATH"
log "HOME: $HOME"

# Check specific tool locations
log "=== Tool Locations ==="
for tool in pipx tte eza zoxide fastfetch cargo mise; do
    location=$(PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH" which $tool 2>/dev/null || echo "not found")
    log "$tool: $location"
done

# Check if tools are in expected locations but not in PATH
log "=== Checking expected locations ==="
expected_locations=(
    "$HOME/.local/bin/tte"
    "$HOME/.local/bin/pipx"
    "$HOME/.cargo/bin/cargo"
    "$HOME/.local/bin/mise"
    "/usr/local/bin/fd"
    "/usr/local/bin/bat"
    "/usr/local/bin/rg"
)

for location in "${expected_locations[@]}"; do
    if [[ -f "$location" ]]; then
        log "✓ Found: $location"
    else
        warning "✗ Missing: $location"
    fi
done

# Summary
log "=== Test Summary ==="
log "Successfully installed: ${#successful_installs[@]} tools"
log "Failed to install: ${#failed_commands[@]} tools"

if [[ ${#failed_commands[@]} -gt 0 ]]; then
    warning "Commands not found: ${failed_commands[*]}"
fi

if [[ ${#alternate_found[@]} -gt 0 ]]; then
    warning "Alternate commands found (symlinks may be needed):"
    for alt in "${alternate_found[@]}"; do
        warning "  $alt"
    done
fi

log "Note: This test runs in Docker which has systemd limitations"
log "Some services (snapd, power-profiles-daemon) may not start properly"
log "For full testing, run on a real Ubuntu 25.04 system with GUI capabilities"

# Exit with success
exit 0