#!/bin/bash
#
# Dotfiles Repository Setup Script
# This script will help you create a git repository of your current configuration
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

DOTFILES_DIR="$HOME/dotfiles"

# Create dotfiles repository
create_repo() {
    log "Creating dotfiles repository..."
    
    mkdir -p "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    
    if [ ! -d ".git" ]; then
        git init
        log "Initialized git repository"
    fi
    
    # Copy important configuration files
    log "Copying configuration files..."
    
    # Copy shell configs
    cp "$HOME/.bashrc" . 2>/dev/null || warn ".bashrc not found"
    cp "$HOME/.zshrc" . 2>/dev/null || warn ".zshrc not found" 
    cp "$HOME/.gtkrc-2.0" . 2>/dev/null || warn ".gtkrc-2.0 not found"
    cp "$HOME/.Xresources" . 2>/dev/null || warn ".Xresources not found"
    
    # Copy .config directory with important configs
    mkdir -p .config
    
    # Important config directories to include
    local config_dirs=(
        "hypr"
        "waybar"
        "kitty"
        "wallust"
        "fastfetch"
        "rofi"
        "swaync"
        "wlogout"
        "ml4w"
        "nwg-dock-hyprland"
        "starship.toml"
        "dunst"
        "btop"
        "cava"
        "foot"
        "fuzzel"
        "anyrun"
        "swappy"
        "fontconfig"
        "gtk-3.0"
        "gtk-4.0"
        "qt5ct"
        "qt6ct"
        "Kvantum"
        "zshrc"
        "bashrc"
    )
    
    for dir in "${config_dirs[@]}"; do
        if [ -e "$HOME/.config/$dir" ]; then
            cp -r "$HOME/.config/$dir" .config/
            log "Copied $dir"
        else
            warn "$dir not found, skipping"
        fi
    done
    
    # Copy wallpapers if they exist
    if [ -d "$HOME/.config/ml4w/wallpapers" ]; then
        log "Copying wallpapers..."
        mkdir -p .config/ml4w/wallpapers
        cp -r "$HOME/.config/ml4w/wallpapers/"* .config/ml4w/wallpapers/ 2>/dev/null || true
    fi
}

# Create package list
create_package_list() {
    log "Creating package lists..."
    
    # Official packages
    pacman -Qe | grep -v "$(pacman -Qm | cut -d' ' -f1 | tr '\n' '|' | sed 's/|$//')" > packages-official.txt
    
    # AUR packages
    pacman -Qm > packages-aur.txt
    
    log "Package lists created:"
    log "- packages-official.txt ($(wc -l < packages-official.txt) packages)"
    log "- packages-aur.txt ($(wc -l < packages-aur.txt) packages)"
}

# Create gitignore
create_gitignore() {
    log "Creating .gitignore..."
    
    cat > .gitignore << 'EOF'
# Sensitive files
*.log
*.cache
**/cache/
**/logs/
**/*.log
**/.cache/

# Large/binary files
**/*.jpg
**/*.jpeg
**/*.png
**/*.gif
**/*.mp4
**/*.mkv
**/*.iso

# Exclude certain config directories that are auto-generated or contain sensitive data
.config/pulse/
.config/systemd/
.config/dconf/
.config/session/
.config/autostart/
.config/chromium*/
.config/teams/
.config/Microsoft*/
.config/yay/
.config/go/
.config/nvim/
.config/github-copilot/

# Backup files
*.backup
*.bak
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF
}

# Create README
create_readme() {
    log "Creating README.md..."
    
    cat > README.md << 'EOF'
# My Dotfiles - ML4W Hyprland Setup

This repository contains my complete system configuration for Arch Linux with ML4W Hyprland.

## Features

- **Hyprland** - Wayland compositor with ML4W configuration
- **Wallust** - Automatic color theming from wallpapers
- **Kitty** - Terminal with color synchronization
- **Waybar** - Status bar with custom themes
- **Starship** - Command prompt with color integration
- **Fastfetch** - System info with themed colors
- **Rofi** - Application launcher
- **SwayNC** - Notification center

## Quick Setup

1. Install Arch Linux
2. Download and run the setup script:
   ```bash
   curl -O https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/setup-system.sh
   chmod +x setup-system.sh
   ./setup-system.sh
   ```

## Manual Installation

### Install packages:
```bash
# Install official packages
sudo pacman -S $(grep -o '^[^[:space:]]*' packages-official.txt | tr '\n' ' ')

# Install AUR packages (requires yay)
yay -S $(grep -o '^[^[:space:]]*' packages-aur.txt | tr '\n' ' ')
```

### Setup dotfiles:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Link configuration files
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0
ln -sf ~/dotfiles/.Xresources ~/.Xresources

# Copy config directory
rsync -av ~/dotfiles/.config/ ~/.config/
```

## Configuration

### Wallust Color Theming
The system uses wallust to generate color themes from wallpapers:
- Kitty terminal colors: `~/.config/kitty/colors-wallust.conf`
- Waybar colors: `~/.config/waybar/themes/starter/colors-wallust.css`
- Starship prompt colors: `~/.config/starship.toml`

### Changing Wallpapers
Use `waypaper` to set wallpapers. Colors will automatically update across all applications.

## Customization

Key configuration files:
- Hyprland: `~/.config/hypr/hyprland.conf`
- Waybar: `~/.config/waybar/themes/starter/`
- Kitty: `~/.config/kitty/kitty.conf`
- Starship: `~/.config/starship.toml`
- Wallust: `~/.config/wallust/wallust.toml`

## Dependencies

See `packages-official.txt` and `packages-aur.txt` for complete package lists.

## License

Feel free to use and modify these configurations for your own setup.
EOF
}

# Setup git and commit
setup_git() {
    log "Setting up git configuration..."
    
    # Check if git user is configured
    if ! git config user.name &>/dev/null; then
        echo "Enter your name for git commits:"
        read -r git_name
        git config user.name "$git_name"
    fi
    
    if ! git config user.email &>/dev/null; then
        echo "Enter your email for git commits:"
        read -r git_email
        git config user.email "$git_email"
    fi
    
    # Add and commit files
    git add .
    git commit -m "Initial dotfiles commit - ML4W Hyprland setup" || warn "Nothing to commit"
    
    log "Git repository ready!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Create a repository on GitHub/GitLab"
    echo "2. Add remote: git remote add origin YOUR_REPO_URL"
    echo "3. Push: git push -u origin main"
    echo "4. Update the repository URL in setup-system.sh"
    echo ""
    echo -e "${YELLOW}Repository location:${NC} $DOTFILES_DIR"
}

# Main execution
main() {
    log "Creating dotfiles repository..."
    echo "This will create a git repository with your current configuration"
    echo "Press Enter to continue or Ctrl+C to cancel"
    read -r
    
    create_repo
    create_package_list
    create_gitignore
    create_readme
    setup_git
    
    log "Dotfiles repository created successfully! 🎉"
}

# Run main function
main "$@" 