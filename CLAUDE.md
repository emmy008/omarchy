# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Omarchy is an opinionated Ubuntu configuration system that transforms a fresh Ubuntu Server installation into a fully-configured Hyprland-based development environment. It provides automated installation scripts, theme management, and system configuration tools.

## Key Commands

### Development
- **Add a new migration**: `omarchy-dev-add-migration` - Creates a new timestamped migration file in `migrations/` directory
- **Run migrations**: `omarchy-migrate` - Executes pending migrations (tracks state in `~/.local/state/omarchy/migrations/`)
- **Update Omarchy**: `omarchy-update` - Pulls latest changes, runs migrations, and updates system packages

### Theme Management
- **Install theme**: `omarchy-theme-install <git-repo-url>`
- **Set theme**: `omarchy-theme-set <theme-name>`
- **Update theme**: `omarchy-theme-update`
- **Remove theme**: `omarchy-theme-remove <theme-name>`

### System Refresh Commands
- **Waybar**: `omarchy-refresh-waybar`
- **Walker**: `omarchy-refresh-walker`
- **Plymouth**: `omarchy-refresh-plymouth`
- **SwayOSD**: `omarchy-refresh-swayosd`
- **Applications**: `omarchy-refresh-applications`
- **Config**: `omarchy-refresh-config`
- **Hypridle**: `omarchy-refresh-hypridle`
- **Hyprlock**: `omarchy-refresh-hyprlock`

## Architecture

### Directory Structure
- `bin/` - All omarchy command-line tools
- `install/` - Installation scripts organized by category (apps/, config/, desktop/, development/, preflight/)
- `config/` - User configuration files for various applications
- `default/` - Default configuration templates
- `themes/` - Available themes with their specific configurations
- `migrations/` - Timestamped migration scripts for updates
- `applications/` - Desktop application entries and icons

### Key Entry Points
- `boot.sh` - Initial bootstrap script that clones the repository and starts installation
- `install.sh` - Main installation orchestrator that sources scripts from `install/` directory
- `bin/omarchy` - Main CLI interface using `gum` for interactive menus

### Migration System
Migrations are timestamped shell scripts in `migrations/` that run once during updates. The system tracks which migrations have been applied in `~/.local/state/omarchy/migrations/`. To create a new migration, use `omarchy-dev-add-migration` which generates a file named with the current Unix timestamp.

### Theme System
Themes are stored in `themes/` directory with each theme containing:
- Terminal colors (`alacritty.toml`)
- Window manager config (`hyprland.conf`, `hyprlock.conf`)
- UI components (`waybar.css`, `walker.css`, `swayosd.css`)
- Editor theme (`neovim.lua`)
- Background images in `backgrounds/`
- Icon theme (`icons.theme`)
- Optional `light.mode` file for light themes

### Installation Process
1. `boot.sh` clones the repository to `~/.local/share/omarchy/`
2. `install.sh` runs scripts in order: preflight → config → development → desktop → apps
3. Each script is self-contained and handles specific aspects of system configuration
4. Post-install migrations handle updates and new features

## Ubuntu Conversion Project State

### Testing Infrastructure

#### Docker Testing
- **File**: `Dockerfile.test` - Uses Ubuntu 25.04 base image
- **Command**: `./run-ubuntu-test.sh` - Automated Docker testing
- **Compose**: `docker-compose.test.yml` - Test orchestration
- **Test Script**: `test-install.sh` - Core installation validation
- **Output**: `test-results/test-output.log` - Test results and debugging
- **Limitations**: Docker lacks full systemd support, some services fail (snapd, power-profiles-daemon)

#### LXC Testing (Recommended)
- **Setup**: `./lxc-test-setup.sh` - Initializes LXD environment with custom profile
- **Runner**: `./run-lxc-test.sh` - Full installation test with systemd support
- **Container**: `omarchy-test-ubuntu` with 2GB RAM, 2 CPUs
- **Benefits**: Full systemd functionality, service testing, persistent containers
- **Reset**: `lxc restore omarchy-test-ubuntu fresh` - Quick environment reset

### Ubuntu vs Arch Differences

#### Package Management
- **Base**: `apt` instead of `pacman`/`yay`
- **Helper Library**: `install/lib/package-manager.sh` - Abstraction layer for cross-distribution support
- **PPAs Required**: Additional repositories for eza, fastfetch, alacritty
- **Snap Integration**: Used for packages not available in main repos (btop fallback)

#### Package Name Mappings
- `fd-find` → `fd` (symlink created at `/usr/local/bin/fd`)
- `batcat` → `bat` (symlink created at `/usr/local/bin/bat`)
- `ripgrep` → `rg` (symlink created at `/usr/local/bin/rg`)
- Standard packages: `git`, `curl`, `wget`, `jq`, `fzf` (same names)

#### Service Management
- Full systemd support (unlike original Arch-focused design)
- Power management via `power-profiles-daemon` instead of Arch alternatives
- Network management integrates with Ubuntu's NetworkManager
- Bluetooth through standard Ubuntu bluetooth stack

### Testing Commands and Workflows

#### Quick Docker Test
```bash
./run-ubuntu-test.sh          # Run automated Docker test
less test-results/test-output.log  # View results
```

#### Full LXC Test (Recommended)
```bash
./lxc-test-setup.sh           # One-time setup
./run-lxc-test.sh             # Run full test
lxc exec omarchy-test-ubuntu -- su - testuser  # Manual testing
lxc restore omarchy-test-ubuntu fresh          # Reset for retest
```

#### Manual Testing
```bash
# In container/test environment
cd ~/.local/share/omarchy
bash install.sh              # Run installation
omarchy                       # Test CLI interface
omarchy-theme-set catppuccin  # Test theme system
```

### Known Issues and Workarounds

#### Docker Environment
- **Issue**: systemd services fail (snapd, power-profiles-daemon)
- **Workaround**: Use LXC for full testing, Docker for quick validation only
- **Impact**: Limited service testing, some package installations may fail

#### Package Installation
- **Issue**: Some tools install with different names on Ubuntu
- **Solution**: Automatic symlink creation in `install/development/terminal.sh`
- **Verification**: Test script checks for both original and Ubuntu package names

#### Path Management
- **Issue**: Newly installed tools not immediately available in PATH
- **Solution**: Scripts explicitly update PATH and source environment files
- **Testing**: Test scripts verify tool availability with updated PATH

#### Snap Package Issues
- **Issue**: Snap may not be available in containerized environments
- **Workaround**: Fallback to apt packages when snap fails
- **Example**: btop installation falls back to apt if snap unavailable

### Current Project Status
- ✅ Core installation scripts converted to Ubuntu
- ✅ Package name mappings implemented with symlinks
- ✅ Docker and LXC testing infrastructure complete
- ✅ Migration system operational
- ✅ Theme system fully functional
- 🔄 Ongoing: Service integration refinements
- 📋 Next: GUI component testing (requires display environment)

## Important Notes
- All file paths in bin scripts use absolute paths starting from `~/.local/share/omarchy/`
- The system uses `apt` as the package manager with additional PPAs, snap, and cargo for packages not in main repos
- Git operations use `--autostash` to preserve local modifications during updates
- The main branch is `master` (not `main`)
- Many Hyprland components need to be built from source on Ubuntu
- Package name mappings: `fd-find` → `fd`, `batcat` → `bat` (symlinks created during install)
- Use LXC testing for complete validation; Docker testing is for quick checks only
- Test environments support both Ubuntu 24.04 LTS and 25.04