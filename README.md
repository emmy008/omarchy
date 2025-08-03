# Omarchy for Ubuntu

> **This is a fork of the original [Omarchy](https://github.com/basecamp/omarchy) project, modified to support Ubuntu instead of Arch Linux.**

Turn a fresh Ubuntu Server installation into a fully-configured, beautiful, and modern web development system based on Hyprland by running a single command. That's the one-line pitch for Omarchy (like it was for Omakub). No need to write bespoke configs for every essential tool just to get started or to be up on all the latest command-line tools. Omarchy is an opinionated take on what Linux can be at its best.

## What's Different in This Fork?

This fork modifies Omarchy to work with Ubuntu (tested on Ubuntu 25.04) instead of Arch Linux:

- **Package Management**: Uses `apt` instead of `pacman`/`yay`
- **AUR Alternatives**: Implements PPAs, snap packages, and builds from source for packages not in Ubuntu repos
- **Hyprland**: Builds Hyprland and its ecosystem from source since it's not in Ubuntu repositories
- **Compatibility**: Handles Ubuntu's different package naming conventions (e.g., `fd-find` → `fd`, `batcat` → `bat`)

Read more about the original Omarchy at [omarchy.org](https://omarchy.org).

## Installation

### Prerequisites

- Fresh Ubuntu Server 25.04 installation
- User with sudo privileges
- Internet connection

### Quick Install

```bash
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/omarchy-ubuntu/main/boot.sh | bash
```

## Testing

### Docker Testing (Basic)

For basic testing of installation scripts:

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/omarchy-ubuntu.git
cd omarchy-ubuntu

# Run the Docker-based test
./run-ubuntu-test.sh
```

Note: Docker has limitations with systemd services, so some components may not work properly.

### LXC/LXD Testing (Recommended)

For comprehensive testing with full systemd support:

```bash
# Setup LXD environment (first time only)
./lxc-test-setup.sh

# Run the installation test
./run-lxc-test.sh
```

The LXC environment provides:
- Full systemd support (snapd, power-profiles-daemon work properly)
- More accurate simulation of a real Ubuntu Server
- Ability to test all Omarchy features including desktop components
- Easy reset to fresh state with snapshots

To access the test container:
```bash
lxc exec omarchy-test-ubuntu -- su - testuser
```

To reset container to fresh state:
```bash
lxc restore omarchy-test-ubuntu fresh
```

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).

