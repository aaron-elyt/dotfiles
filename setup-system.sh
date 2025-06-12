#!/bin/bash
#
# System Replication Script for ML4W Hyprland Setup
# This script will replicate the complete system configuration on a new Arch Linux machine
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running on Arch Linux
check_arch() {
    if ! grep -q "ID=arch" /etc/os-release; then
        error "This script is designed for Arch Linux"
    fi
    log "Arch Linux detected ✓"
}

# Update system
update_system() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm
}

# Install yay AUR helper if not present
install_yay() {
    if ! command -v yay &> /dev/null; then
        log "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
    else
        log "yay already installed ✓"
    fi
}

# Install essential packages
install_packages() {
    log "Installing essential packages..."
    
    # Core system packages
    local packages=(
        # Base packages
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "vim"
        "nano"
        
        # ML4W Hyprland and dependencies
        "hyprland"
        "waybar"
        "rofi-wayland" 
        "swaync"
        "swww"
        "xdg-desktop-portal-hyprland"
        "hyprland-qtutils"
        "nwg-dock-hyprland"
        
        # Terminal and shell
        "kitty"
        "starship"
        "zsh"
        "fish"
        
        # Color theming (matugen comes from AUR below)
        
        # System info and utilities
        "fastfetch"
        "btop"
        "cava"
        
        # File managers and utilities
        "thunar"
        "nautilus"
        # 'waypaper' comes from AUR below
        
        # Fonts and theming
        "noto-fonts"
        "noto-fonts-emoji" 
        "ttf-font-awesome"
        "nwg-look"
        "qt5ct"
        "qt6ct"
        
        # Audio
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "pipewire-jack"
        "pavucontrol"
        
        # Other utilities
        "firefox"
        "code"
        "grim"
        "slurp"
        "swappy"
        "mousepad"
    )
    
    # Install official packages
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # AUR packages
    local aur_packages=(
        "ml4w-hyprland"
        "waypaper"
        "wallust"
        "grimblast-git"
        "hyprshade"
        "textsnatcher"
        "anyrun"
        "fuzzel"
        # Fonts
        "ttf-gabarito-git"
        "ttf-material-symbols-variable-git"
        "ttf-ms-fonts"
        "ttf-readex-pro"
        "ttf-rubik-vf"
        "ttf-victor-mono"
        "matugen"
    )
    
    log "Installing AUR packages..."
    yay -S --needed --noconfirm "${aur_packages[@]}"
}

# Setup dotfiles
setup_dotfiles() {
    log "Setting up dotfiles..."
    
    # Clone or update dotfiles repository
    DOTFILES_DIR="$HOME/dotfiles"
    if [ ! -d "$DOTFILES_DIR" ]; then
        log "Please provide your dotfiles repository URL:"
        read -r DOTFILES_REPO
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        log "Dotfiles directory already exists"
    fi
    
    # Backup existing configs
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    if [ -d "$HOME/.config" ]; then
        log "Backing up existing config to $BACKUP_DIR"
        cp -r "$HOME/.config" "$BACKUP_DIR"
    fi
    
    # Link dotfiles
    log "Linking dotfiles..."
    ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.gtkrc-2.0" "$HOME/.gtkrc-2.0" 
    ln -sf "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
    
    # Link config directory
    if [ -d "$DOTFILES_DIR/.config" ]; then
        rsync -av "$DOTFILES_DIR/.config/" "$HOME/.config/"
    fi
}

# Configure shell
setup_shell() {
    log "Setting up shell configuration..."
    
    # Change shell to zsh if not already
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        log "Changing shell to zsh..."
        chsh -s /usr/bin/zsh
    fi
    
    # Ensure starship is initialized
    if ! grep -q "starship init" "$HOME/.zshrc"; then
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    fi
}

# Setup ML4W Hyprland
setup_ml4w() {
    log "Setting up ML4W Hyprland..."
    
    # Run ML4W installer if needed
    if [ ! -d "$HOME/.config/hypr" ] || [ ! -f "$HOME/.config/hypr/hyprland.conf" ]; then
        log "Running ML4W Hyprland installer..."
        ml4w-hyprland-setup
    else
        log "ML4W Hyprland already configured ✓"
    fi
}

# Setup wallust templates and integration
setup_wallust() {
    log "Setting up wallust integration..."
    
    # Ensure wallust directories exist
    mkdir -p "$HOME/.config/wallust/templates"
    
    # Check if wallust config exists
    if [ ! -f "$HOME/.config/wallust/wallust.toml" ]; then
        warn "Wallust config not found, creating basic config..."
        cat > "$HOME/.config/wallust/wallust.toml" << 'EOF'
[settings]
palette = "dark16"
check_contrast = false
backend = "resized"

[[template]]
template = "colors-kitty.conf"
target = "~/.config/kitty/colors-wallust.conf"

[[template]]
template = "waybar-colors.css"
target = "~/.config/waybar/themes/starter/colors-wallust.css"

[[template]]
template = "starship-colors.toml" 
target = "~/.config/starship.toml"
EOF
    fi
}

# Make scripts executable
setup_scripts() {
    log "Making scripts executable..."
    
    # Find and make shell scripts executable
    find "$HOME/.config" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Specific scripts that should be executable
    local scripts=(
        "$HOME/.config/hypr/scripts/wallpaper.sh"
        "$HOME/.config/wallust/update-starship-colors.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            log "Made $script executable"
        fi
    done
}

# Generate initial wallust colors
generate_colors() {
    log "Generating initial wallust colors..."
    
    # Run wallust on a default wallpaper if available
    WALLPAPER_DIR="$HOME/.config/ml4w/wallpapers"
    if [ -d "$WALLPAPER_DIR" ]; then
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | head -n 1)
        if [ -n "$WALLPAPER" ]; then
            log "Running wallust on $WALLPAPER"
            wallust "$WALLPAPER" 2>/dev/null || warn "Failed to generate wallust colors"
        fi
    fi
}

# Enable services
enable_services() {
    log "Enabling system services..."
    
    systemctl --user enable --now pipewire
    systemctl --user enable --now pipewire-pulse
}

# Post-installation notes
show_notes() {
    log "Installation complete! 🎉"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Logout and login again to apply shell changes"
    echo "2. Start Hyprland session"
    echo "3. Run 'waypaper' to set your wallpaper and generate colors"
    echo "4. Customize your configs in ~/.config/"
    echo ""
    echo -e "${BLUE}Key features installed:${NC}"
    echo "• Hyprland with ML4W configuration"
    echo "• Wallust automatic color theming"
    echo "• Kitty terminal with color sync"
    echo "• Waybar with custom themes"
    echo "• Starship prompt with color integration"
    echo "• Fastfetch with color theming"
    echo ""
    echo -e "${YELLOW}Note:${NC} Your original configs were backed up to $BACKUP_DIR"
}

# Main execution
main() {
    log "Starting system replication script..."
    echo "This will install and configure a complete ML4W Hyprland setup"
    echo "Press Enter to continue or Ctrl+C to cancel"
    read -r
    
    check_arch
    update_system
    install_yay
    install_packages
    setup_dotfiles
    setup_shell
    setup_ml4w
    setup_wallust
    setup_scripts
    generate_colors
    enable_services
    show_notes
}

# Run main function
main "$@" 