#!/bin/bash

# Package Manager Helper Functions
# Provides cross-distribution package management abstraction

# Install packages using the appropriate package manager
# Usage: install_packages package1 package2 ...
install_packages() {
    local packages=("$@")
    
    if command -v apt &>/dev/null; then
        # Ubuntu/Debian
        sudo apt install -y "${packages[@]}"
    elif command -v pacman &>/dev/null; then
        # Arch Linux
        if command -v yay &>/dev/null; then
            yay -S --noconfirm --needed "${packages[@]}"
        else
            sudo pacman -S --noconfirm --needed "${packages[@]}"
        fi
    else
        echo "Error: No supported package manager found"
        return 1
    fi
}

# Install AUR packages (Arch only) or equivalent from other sources
# Usage: install_aur_packages package1 package2 ...
install_aur_packages() {
    local packages=("$@")
    
    if command -v yay &>/dev/null; then
        # Arch Linux with yay
        yay -S --noconfirm --needed "${packages[@]}"
    elif command -v pacman &>/dev/null; then
        # Arch Linux without yay - warn user
        echo "Warning: AUR packages requested but yay not installed: ${packages[*]}"
        echo "Please install yay first or manually install these packages"
        return 1
    else
        # Ubuntu/Debian - packages might not be available
        echo "Note: The following AUR packages are not available on Ubuntu: ${packages[*]}"
        echo "Please find Ubuntu alternatives or build from source"
        return 1
    fi
}

# Check if we're on Arch Linux
is_arch() {
    command -v pacman &>/dev/null
}

# Check if we're on Ubuntu/Debian
is_ubuntu() {
    command -v apt &>/dev/null
}

# Update package database
update_packages() {
    if is_ubuntu; then
        sudo apt update
    elif is_arch; then
        sudo pacman -Sy
    fi
}

# Export functions for use in sourced scripts
export -f install_packages
export -f install_aur_packages
export -f is_arch
export -f is_ubuntu
export -f update_packages