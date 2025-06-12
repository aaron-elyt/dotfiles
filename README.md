# ML4W Hyprland Configuration

This repository contains my complete system configuration for Arch Linux with ML4W Hyprland, optimized for both NVIDIA and non-NVIDIA systems.

## Features

- **Hyprland** - Tiling Wayland compositor with ML4W configuration
- **Wallust** - Automatic color theming from wallpapers
- **Kitty** - Terminal with color synchronization
- **Waybar** - Status bar with custom themes
- **Starship** - Command prompt with color integration
- **Fastfetch** - System info with themed colors
- **Custom Apps** - Configured Chromium apps for WhatsApp, Teams, and Webflow

## Quick Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   cd ~/dotfiles
   chmod +x setup-system.sh
   ./setup-system.sh
   ```

## Manual Installation

### Install Base Packages:
```bash
# Install official packages
sudo pacman -S $(cat pkg-repo.txt | cut -d' ' -f1)

# Install AUR packages (requires yay)
yay -S $(cat pkg-aur.txt | cut -d' ' -f1)
```

### NVIDIA Setup
If you're using an NVIDIA GPU, additional configuration is required:

1. Install NVIDIA drivers:
   ```bash
   sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils
   ```

2. Add these environment variables to `/etc/environment`:
   ```bash
   LIBVA_DRIVER_NAME=nvidia
   XDG_SESSION_TYPE=wayland
   GBM_BACKEND=nvidia-drm
   __GLX_VENDOR_LIBRARY_NAME=nvidia
   WLR_NO_HARDWARE_CURSORS=1
   ```

3. The Hyprland configuration already includes NVIDIA-specific settings.

## Configuration Files

- **Window Manager**: `~/.config/hypr/`
- **Status Bar**: `~/.config/waybar/`
- **Terminal**: `~/.config/kitty/`
- **Shell**: `.zshrc` and `~/.config/starship.toml`
- **Theme**: `~/.config/wallust/`
- **Applications**: `~/.local/share/applications/`

## Custom Applications

The setup includes custom Chromium apps:
- WhatsApp Web
- Microsoft Teams
- Webflow

## Post-Installation

1. Set your wallpaper:
   ```bash
   waypaper
   ```

2. Generate color scheme:
   ```bash
   wallust
   ```

3. Restart your session to apply all changes.

## Updating

To update your dotfiles:
```bash
cd ~/dotfiles
git pull
./setup-system.sh
```

## License

Feel free to use and modify these configurations for your own setup. 