#!/bin/bash

# Package manager abstraction layer for easier cross-distribution support

# Function to install packages
omarchy_install() {
  sudo apt install -y "$@"
}

# Function to check if a package is installed
omarchy_is_installed() {
  dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Function to update package database
omarchy_update() {
  sudo apt update
}

# Function to upgrade all packages
omarchy_upgrade() {
  sudo apt upgrade -y
}

# Function to search for packages
omarchy_search() {
  apt search "$@"
}

# Function to remove packages
omarchy_remove() {
  sudo apt remove -y "$@"
}

# Export functions for use in other scripts
export -f omarchy_install
export -f omarchy_is_installed
export -f omarchy_update
export -f omarchy_upgrade
export -f omarchy_search
export -f omarchy_remove