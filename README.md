# Omarchy for Ubuntu

> **A fork of [basecamp/omarchy](https://github.com/basecamp/omarchy) adapted for Ubuntu systems**

Transform a fresh Ubuntu Server installation into a fully-configured, beautiful, and modern Hyprland-based development environment with a single command. Omarchy brings the same opinionated, batteries-included approach of the original Arch-based system to Ubuntu users.

## What is Omarchy?

Omarchy is an opinionated Ubuntu configuration system that provides:
- **Hyprland** window manager with a complete desktop environment
- **Modern CLI tools** like eza, bat, fd, ripgrep, zoxide, and more
- **Development environment** with pre-configured terminals, editors, and tools
- **Theme system** with beautiful defaults and easy customization
- **Migration system** for seamless updates

Read more about the original project at [omarchy.org](https://omarchy.org).

## Ubuntu Adaptation Overview

This fork adapts the original Arch-based Omarchy for Ubuntu systems (tested on Ubuntu 24.04 LTS and 25.04):

### Package Management
- **Abstraction Layer**: Custom package manager wrapper (`install/lib/package-manager.sh`) provides distribution-agnostic installation
- **Multiple Sources**: Leverages apt, PPAs, snap, cargo, pipx, and source builds as needed
- **Smart Fallbacks**: Gracefully handles missing packages with alternative installation methods

### Key Differences from Arch Version

| Component | Arch Original | Ubuntu Adaptation |
|-----------|--------------|-------------------|
| Package Manager | pacman/yay | apt with PPAs |
| AUR Packages | Direct from AUR | PPAs, snap, cargo, or source builds |
| Hyprland | AUR packages | PPA (ppa:cppiber/hyprland) |
| Service Manager | systemd | systemd (full support) |
| Power Management | Various | power-profiles-daemon |
| Package Names | Standard | Mapped (fd-find→fd, batcat→bat) |

### Ubuntu-Specific Features
- **Package Name Mappings**: Automatic symlink creation for Ubuntu's different naming conventions
- **PPA Management**: Targeted repository updates for faster installation
- **Build Dependencies**: Automatically installs development tools when building from source
- **Version Detection**: Adapts installation methods based on Ubuntu version

## Requirements

- **Ubuntu Server** 24.04 LTS or 25.04 (fresh installation recommended)
- **User account** with sudo privileges
- **Internet connection** for package downloads
- **Minimum 4GB RAM** for Hyprland desktop environment
- **20GB+ free disk space** for full installation

## Installation

### One-Line Install

```bash
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/omarchy-ubuntu/main/boot.sh | bash
```

This will:
1. Clone the repository to `~/.local/share/omarchy/`
2. Run the installation scripts in order (preflight → config → development → desktop → apps)
3. Configure all tools and environments
4. Set up the default theme (Catppuccin)

### Manual Installation

```bash
git clone https://github.com/YOUR-USERNAME/omarchy-ubuntu.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
bash install.sh
```

## What Gets Installed

### Development Tools
- **Modern CLI**: eza, bat, fd, ripgrep, fzf, zoxide, gum, tte
- **Version Control**: git with delta diff viewer
- **Package Managers**: cargo, pipx, npm
- **Terminals**: Alacritty, foot
- **Editors**: Neovim, VS Code

### Desktop Environment
- **Window Manager**: Hyprland with full ecosystem
- **Launcher**: Walker application launcher
- **Bar**: Waybar with custom configuration
- **Notifications**: SwayNotificationCenter
- **Screenshots**: Hyprshot
- **Lock Screen**: Hyprlock with Hypridle

### System Tools
- **File Manager**: Nautilus, Yazi (terminal)
- **Browser**: Google Chrome
- **Media**: VLC, Spotify
- **Communication**: Discord
- **Utilities**: btop, ncdu, trash-cli

## Post-Installation

### Available Commands

After installation, you'll have access to the Omarchy command suite:

- `omarchy` - Main interactive menu
- `omarchy-update` - Update Omarchy and run migrations
- `omarchy-theme-set <name>` - Change active theme
- `omarchy-theme-install <git-url>` - Install new theme
- `omarchy-refresh-*` - Refresh various components (waybar, walker, etc.)

### Theme Management

Omarchy includes a powerful theme system:

```bash
# Set a different theme
omarchy-theme-set gruvbox

# Install a custom theme from Git
omarchy-theme-install https://github.com/user/my-theme.git

# Update current theme
omarchy-theme-update
```

## Development

### Adding Migrations

When adding new features or updates:

```bash
# Create a new migration file
omarchy-dev-add-migration

# Edit the generated migration file in migrations/
# Migrations run automatically during omarchy-update
```

### Package Manager Abstraction

The Ubuntu fork includes a package manager abstraction layer in `install/lib/package-manager.sh`:

```bash
# Use these functions in installation scripts
omarchy_install package_name
omarchy_is_installed package_name
omarchy_update
omarchy_upgrade
```

## Troubleshooting

### Common Issues

**Hyprland not starting**: Ensure you have proper GPU drivers installed and Wayland support enabled.

**Package not found**: Some packages may require PPAs to be added first. Check the installation logs.

**Symlinks not working**: The installation creates symlinks for Ubuntu-specific package names. Run `omarchy-update` to recreate them.

**Snap packages failing**: In containerized environments, snap may not work properly due to systemd limitations.

### Getting Help

- Check the [original Omarchy documentation](https://omarchy.org)
- Open an issue in the repository

## Contributing

This fork maintains compatibility with the upstream Omarchy project while adding Ubuntu-specific features. When contributing:

1. Ensure package installations work on both Ubuntu 24.04 LTS and 25.04
2. Use the package manager abstraction layer for distribution compatibility
3. Document any new Ubuntu-specific adaptations

## Credits

- Original [Omarchy](https://github.com/basecamp/omarchy) project by Basecamp
- Ubuntu adaptation and testing infrastructure by this fork's contributors

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).

---

*Note: Remember to update `YOUR-USERNAME` in the installation URLs to your actual GitHub username.*

