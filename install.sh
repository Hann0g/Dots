#!/bin/bash

# Arch Linux Hyprland Installation Script
# Run this script after a fresh Arch Linux installation

set -e  # Exit on any error

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
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
   exit 1
fi

# Check if yay is installed, if not install it
install_yay() {
    if ! command -v yay &> /dev/null; then
        log "Installing yay AUR helper..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
    else
        log "yay is already installed"
    fi
}

# Update system
update_system() {
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm
}

# Install essential packages
install_essentials() {
    log "Installing essential packages..."
    
    # Base system packages
    local base_packages=(
        base-devel
        git
        wget
        curl
        unzip
        vim
        nano
        htop
        fastfetch
        tree
        man-db
        man-pages
    )
    
    sudo pacman -S --needed --noconfirm "${base_packages[@]}"
}

# Install Hyprland and Wayland essentials
install_hyprland() {
    log "Installing Hyprland and Wayland components..."
    
    local hyprland_packages=(
        hyprland
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        qt5-wayland
        qt6-wayland
        wayland
        wayland-protocols
        wayland-utils
        wlroots
        polkit-kde-agent
    )
    
    sudo pacman -S --needed --noconfirm "${hyprland_packages[@]}"
}

# Install display and graphics
install_graphics() {
    log "Installing graphics and display packages..."
    
    local graphics_packages=(
        mesa
        vulkan-radeon      # For AMD
        vulkan-intel       # For Intel
        nvidia-dkms        # For NVIDIA (comment out if not needed)
        nvidia-utils       # For NVIDIA (comment out if not needed)
        libva-mesa-driver
        mesa-vdpau
        xorg-xwayland
    )
    
    # Remove nvidia packages if not using NVIDIA
    read -p "Are you using NVIDIA graphics? (y/n): " nvidia_choice
    if [[ ! "$nvidia_choice" =~ ^[Yy]$ ]]; then
        graphics_packages=("${graphics_packages[@]/nvidia-dkms}")
        graphics_packages=("${graphics_packages[@]/nvidia-utils}")
    fi
    
    sudo pacman -S --needed --noconfirm "${graphics_packages[@]}"
}

# Install audio system
install_audio() {
    log "Installing audio system..."
    
    local audio_packages=(
        pipewire
        pipewire-alsa
        pipewire-pulse
        pipewire-jack
        wireplumber
        pavucontrol
        playerctl
    )
    
    sudo pacman -S --needed --noconfirm "${audio_packages[@]}"
    
    # Enable audio services
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user enable wireplumber.service
}

# Install fonts
install_fonts() {
    log "Installing fonts..."
    
    local font_packages=(
        ttf-dejavu
        ttf-liberation
        noto-fonts
        noto-fonts-emoji
        ttf-fira-code
        ttf-font-awesome
        adobe-source-code-pro-fonts
    )
    
    sudo pacman -S --needed --noconfirm "${font_packages[@]}"
    
    # Install additional fonts from AUR
    yay -S --needed --noconfirm \
        ttf-ms-fonts \
        ttf-jetbrains-mono \
        nerd-fonts-complete
}

# Install terminal and shell
install_terminal() {
    log "Installing terminal applications..."
    
    local terminal_packages=(
        kitty
        alacritty
        fish
        zsh
        zsh-completions
        zsh-syntax-highlighting
        zsh-autosuggestions
    )
    
    sudo pacman -S --needed --noconfirm "${terminal_packages[@]}"
    
    # Install oh-my-zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Change default shell to zsh
    if [[ "$SHELL" != */zsh ]]; then
        log "Changing default shell to zsh..."
        chsh -s $(which zsh)
    fi
}

# Install essential applications
install_applications() {
    log "Installing essential applications..."
    
    local apps=(
        firefox
        chromium
        kitty
        dolphin
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
        waybar
        dunst
        brightnessctl
        networkmanager
        network-manager-applet
        bluez
        bluez-utils
        blueman
        qt5ct
        pamixer
        playerctl
        swaybg
    )
    
    sudo pacman -S --needed --noconfirm "${apps[@]}"
    
    # Install AUR applications
    yay -S --needed --noconfirm \
        swww \
        hyprpicker \
        wlogout \
        sddm-git \
        fuzzel \
        swaync \
        hyprshot \
        hyprlock \
        obsidian \
        foliate
}

# Install development tools
install_dev_tools() {
    read -p "Install development tools? (y/n): " dev_choice
    if [[ "$dev_choice" =~ ^[Yy]$ ]]; then
        log "Installing development tools..."
        
        local dev_packages=(
            code
            git
            github-cli
            nodejs
            npm
            python
            python-pip
            docker
            docker-compose
        )
        
        sudo pacman -S --needed --noconfirm "${dev_packages[@]}"
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        # Enable docker service
        sudo systemctl enable docker.service
    fi
}

# Configure services
configure_services() {
    log "Configuring system services..."
    
    # Enable NetworkManager
    sudo systemctl enable NetworkManager.service
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth.service
    
    # Enable SDDM
    sudo systemctl enable sddm.service
    
    # Configure SDDM for Wayland
    sudo mkdir -p /etc/sddm.conf.d/
    cat << EOF | sudo tee /etc/sddm.conf.d/10-wayland.conf
[General]
DisplayServer=wayland

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF
}

# Setup Fastfetch with anime images
setup_fastfetch() {
    log "Setting up Fastfetch with anime character images..."
    
    # Create fastfetch directory
    mkdir -p ~/.config/fastfetch
    
    # Create the install_date.sh script
    cat << 'EOF' > ~/.config/fastfetch/install_date.sh
#!/bin/bash
# Calculate days since installation
install_date=$(stat -c %W /)
current_date=$(date +%s)
days_since=$((($current_date - $install_date) / 86400))
echo $days_since
EOF
    chmod +x ~/.config/fastfetch/install_date.sh
    
    # Create fastfetch config
    cat << 'EOF' > ~/.config/fastfetch/config.jsonc
//   _____ _____ _____ _____ _____ _____ _____ _____ _____ 
//  |   __|  _  |   __|_   _|   __|   __|_   _|     |  |  |
//  |   __|     |__   | | | |   __|   __| | | |   --|     |
//  |__|  |__|__|_____| |_| |__|  |_____| |_| |_____|__|__|  HYPRLAND
//
//  by Bina

{
    "logo": {
    	"source": "/home/$USER/.config/fastfetch/anime_character.png",
    	"type": "kitty",
    	"height": 16,
    	"padding": {
    		"top": 0
    	}
    },
    "display": {
        "separator": "  ",
    },
    "modules": [
    {
      "key": "╭──────────────╮",
      "type": "custom",
    },
    {
      "key": "│ {#31} user@hname {#keys}│",
      "type": "title",
      "format": "{user-name}@{host-name}",
    },
    {
      "key": "│ {#32}󰥔 uptime     {#keys}│",
      "type": "uptime",
    },
    {
      "key": "│ {#33} distro     {#keys}│",
      "type": "os",
    },
    {
      "key": "│ {#34} kernel     {#keys}│",
      "type": "kernel",
    },
    {
      "key": "│ {#35} term       {#keys}│",
      "type": "terminal",
    },
    {
      "key": "│ {#36} shell      {#keys}│",
      "type": "shell",
    },
    {
      "key": "│ {#31}󰍛 cpu        {#keys}│",
      "type": "cpu",
      "showPeCoreCount": true,
    },
    {
      "type": "gpu",
      "key": "│ {#32}󱤓 gpu        {#keys}│",
      "format": "{2} [{6}]",
    },
    {
      "key": "│ {#33} memory     {#keys}│",
      "type": "memory",
    },
    {
      "key": "│ {#34}󰩟 network    {#keys}│",
      "type": "localip",
      "format": "{ipv4} ({ifname})",
    },
    {
      "key": "│ {#35}󰺎 installed  {#keys}│",
      "type": "command",
      "shell": "/home/$USER/.config/fastfetch/install_date.sh",
      "format": "{result} days ago",
    },
    {
      "key": "├──────────────┤",
      "type": "custom",
    },
    {
      "key": "│ {#39} colors     {#keys}│",
      "type": "colors",
      "symbol": "circle",
    },
    {
      "key": "╰──────────────╯",
      "type": "custom",
    },
  ],
} 
EOF
    
    # Replace $USER with actual username in config file
    sed -i "s/\$USER/$USER/g" ~/.config/fastfetch/config.jsonc
    
    # Create anime character selector script
    cat << 'EOF' > ~/.config/fastfetch/change_anime.sh
#!/bin/bash
# Anime Character Changer for Fastfetch
# Usage: ./change_anime.sh [character_number] or ./change_anime.sh random

FASTFETCH_DIR="$HOME/.config/fastfetch"
CURRENT_IMAGE="$FASTFETCH_DIR/anime_character.png"

# Character options
declare -A characters=(
    [1]="elf_warrior.png"
    [2]="pink_elf.png" 
    [3]="gray_hair_girl.png"
    [4]="gray_hair_sitting.png"
    [5]="pink_elf_portrait.png"
    [6]="chibi_elf.png"
)

# Function to display available characters
show_characters() {
    echo "Available anime characters:"
    echo "1. Elf Warrior (with staff)"
    echo "2. Pink Elf Portrait"
    echo "3. Gray Hair Girl (sitting with hand on head)"
    echo "4. Gray Hair Girl (kneeling)"
    echo "5. Pink Elf Close-up"
    echo "6. Chibi Elf (cute style)"
    echo ""
    echo "Usage: $0 [1-6|random|list]"
}

# Function to change character
change_character() {
    local choice=$1
    local filename=""
    
    if [[ "$choice" == "random" ]]; then
        choice=$((RANDOM % 6 + 1))
        echo "Randomly selected character $choice"
    fi
    
    if [[ "$choice" =~ ^[1-6]$ ]]; then
        filename=${characters[$choice]}
        if [[ -f "$FASTFETCH_DIR/$filename" ]]; then
            cp "$FASTFETCH_DIR/$filename" "$CURRENT_IMAGE"
            echo "Changed to character $choice: $filename"
            echo "Run 'fastfetch' to see the new character!"
        else
            echo "Error: Character image file not found: $FASTFETCH_DIR/$filename"
            echo "Make sure all character images are in $FASTFETCH_DIR/"
        fi
    else
        echo "Invalid choice. Please select 1-6 or 'random'"
        show_characters
    fi
}

# Main script logic
case "${1:-list}" in
    "list"|"")
        show_characters
        ;;
    "random"|[1-6])
        change_character "$1"
        ;;
    *)
        echo "Invalid argument: $1"
        show_characters
        exit 1
        ;;
esac
EOF
    
    chmod +x ~/.config/fastfetch/change_anime.sh
    
    # Create placeholder images (user will need to replace these)
    log "Creating placeholder anime character images..."
    
    # Create simple placeholder images using ImageMagick if available
    if command -v convert &> /dev/null; then
        # Create colored placeholder images
        convert -size 200x300 xc:"#ff6b9d" -fill white -gravity center -pointsize 20 -annotate 0 "Elf\nWarrior" ~/.config/fastfetch/elf_warrior.png
        convert -size 200x200 xc:"#ffc0cb" -fill white -gravity center -pointsize 18 -annotate 0 "Pink\nElf" ~/.config/fastfetch/pink_elf.png
        convert -size 200x250 xc:"#c0c0c0" -fill white -gravity center -pointsize 16 -annotate 0 "Gray Hair\nGirl" ~/.config/fastfetch/gray_hair_girl.png
        convert -size 200x200 xc:"#d3d3d3" -fill white -gravity center -pointsize 16 -annotate 0 "Gray Hair\nSitting" ~/.config/fastfetch/gray_hair_sitting.png
        convert -size 150x150 xc:"#ffb3d9" -fill white -gravity center -pointsize 14 -annotate 0 "Pink Elf\nPortrait" ~/.config/fastfetch/pink_elf_portrait.png
        convert -size 120x120 xc:"#fff0f5" -fill "#8b4513" -gravity center -pointsize 12 -annotate 0 "Chibi\nElf" ~/.config/fastfetch/chibi_elf.png
        
        # Set default character
        cp ~/.config/fastfetch/elf_warrior.png ~/.config/fastfetch/anime_character.png
        
        log "Created placeholder images. Replace them with your anime images!"
    else
        warn "ImageMagick not available. You'll need to manually add your anime character images."
        warn "Place your images in ~/.config/fastfetch/ with these names:"
        echo "  - elf_warrior.png"
        echo "  - pink_elf.png"
        echo "  - gray_hair_girl.png"
        echo "  - gray_hair_sitting.png"
        echo "  - pink_elf_portrait.png"
        echo "  - chibi_elf.png"
        echo "  - anime_character.png (current displayed character)"
    fi
    
    # Add fastfetch alias to shell configs
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            if ! grep -q "alias ff=" "$config"; then
                echo "" >> "$config"
                echo "# Fastfetch aliases" >> "$config"
                echo "alias ff='fastfetch'" >> "$config"
                echo "alias change-anime='~/.config/fastfetch/change_anime.sh'" >> "$config"
            fi
        fi
    done
    
    log "Fastfetch setup complete!"
    warn "To use: Run 'fastfetch' or 'ff' in terminal"
    warn "To change character: Run 'change-anime [1-6]' or 'change-anime random'"
}

# Create personalized Hyprland config
create_hyprland_config() {
    log "Creating personalized Hyprland configuration..."
    
    mkdir -p ~/.config/hypr
    
    cat << 'EOF' > ~/.config/hypr/hyprland.conf
# Autostart applications
exec-once = waybar
exec-once = swaync
exec-once = nm-applet --indicator
exec-once = export QT_QPA_PLATFORMTHEME=qt5ct
exec-once = blueman-applet

# Monitor configuration - adjust as needed for your setup
monitor = , 1920x1080@60, auto, 1 

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
        tap-to-click = yes
    }
}

# Catppuccin Mocha colors
$mocha-rosewater = rgba(f5e0dcff)
$mocha-flamingo  = rgba(f2cdcdff)
$mocha-pink      = rgba(f5c2e7ff)
$mocha-mauve     = rgba(cba6f7ff)
$mocha-red       = rgba(f38ba8ff)
$mocha-maroon    = rgba(eba0acff)
$mocha-peach     = rgba(fab387ff)
$mocha-yellow    = rgba(f9e2afff)
$mocha-green     = rgba(a6e3a1ff)
$mocha-teal      = rgba(94e2d5ff)
$mocha-sky       = rgba(89dcebff)
$mocha-sapphire  = rgba(74c7ecff)
$mocha-blue      = rgba(89b4faff)
$mocha-lavender  = rgba(b4befeff)
$mocha-text      = rgba(cdd6f4ff)
$mocha-subtext1  = rgba(bac2deff)
$mocha-subtext0  = rgba(a6adc8ff)
$mocha-overlay2  = rgba(9399b2ff)
$mocha-overlay1  = rgba(7f849cff)
$mocha-overlay0  = rgba(6c7086ff)
$mocha-surface2  = rgba(585b70ff)
$mocha-surface1  = rgba(45475aff)
$mocha-surface0  = rgba(313244ff)
$mocha-base      = rgba(1e1e2eff)
$mocha-mantle    = rgba(181825ff)
$mocha-crust     = rgba(11111bff)

general {
    gaps_in = 10
    gaps_out = 40
    border_size = 3
    col.active_border = $mocha-maroon
    col.inactive_border = $mocha-maroon
    resize_on_border = false
    allow_tearing = false
    layout = dwindle
}

decoration {
    rounding = 10
    active_opacity = 0.9
    inactive_opacity = 0.3 
    blur {
        enabled = true
        size = 1
        passes = 5
        vibrancy = 0.1696
    }
}

animations {
    enabled = false
}

dwindle {
    pseudotile = true 
    preserve_split = true 
}

master {
    new_status = master
}

misc {
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}

# Keybinds
bind = SUPER, PRINT, exec, hyprshot -m output
bind = SUPER, RETURN, exec, kitty
bind = SUPER, Q, killactive 
bind = SUPER, D, exec, fuzzel
bind = SUPER SHIFT, E, exit
bind = SUPER, F, exec, dolphin
bind = SUPER, S, exec, firefox
bind = SUPER, O, exec, obsidian
bind = SUPER, L, exec, hyprlock
bind = SUPER, B, exec, foliate 
bind = SUPER, A, exec, firefox https://chatgpt.com/
bind = SUPER, Y, exec, firefox https://www.youtube.com/
bind = SUPER, G, exec, firefox https://mail.google.com/mail/u/0/#inbox
bind = SUPER, R, exec, firefox https://www.reddit.com/

# Fastfetch and anime character shortcuts
bind = SUPER, I, exec, kitty --hold fastfetch
bind = SUPER SHIFT, I, exec, kitty --hold ~/.config/fastfetch/change_anime.sh

# Workspaces
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5

# Audio controls
bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl s +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

# Mouse bindings
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow

# Window movement
bind = SUPER SHIFT, H, movewindow, l
bind = SUPER SHIFT, L, movewindow, r
bind = SUPER SHIFT, K, movewindow, u
bind = SUPER SHIFT, J, movewindow, d 
EOF

    log "Hyprland configuration created"
}

# Create Kitty terminal config
create_kitty_config() {
    log "Creating Kitty terminal configuration..."
    
    mkdir -p ~/.config/kitty
    
    cat << 'EOF' > ~/.config/kitty/kitty.conf
# Font configuration
font_family      JetBrains Mono Nerd Font
bold_font        JetBrains Mono Nerd Font Bold
italic_font      JetBrains Mono Nerd Font Italic
bold_italic_font JetBrains Mono Nerd Font Bold Italic
font_size 12.0

# Catppuccin Mocha theme
include current-theme.conf

# Window layout
remember_window_size  yes
initial_window_width  640
initial_window_height 400
window_padding_width 10

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Bell
enable_audio_bell no
visual_bell_duration 0.0

# Mouse
mouse_hide_wait 3.0
url_color #0087bd
url_style curly

# Keybindings
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+enter new_window
map ctrl+shift+t new_tab
EOF

    # Download Catppuccin theme for Kitty
    curl -L -o ~/.config/kitty/current-theme.conf https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf 2>/dev/null || {
        # Fallback if download fails
        cat << 'EOF' > ~/.config/kitty/current-theme.conf
# Catppuccin Mocha
foreground              #CDD6F4
background              #1E1E2E
selection_foreground    #1E1E2E
selection_background    #F5E0DC

# Cursor colors
cursor                  #F5E0DC
cursor_text_color       #1E1E2E

# URL underline color when hovering with mouse
url_color               #F5E0DC

# Kitty window border colors
active_border_color     #B4BEFE
inactive_border_color   #6C7086
bell_border_color       #F9E2AF

# Tab bar colors
active_tab_foreground   #11111B
active_tab_background   #CBA6F7
inactive_tab_foreground #CDD6F4
inactive_tab_background #181825
tab_bar_background      #11111B

# Colors for marks (marked text in the terminal)
mark1_foreground #1E1E2E
mark1_background #B4BEFE
mark2_foreground #1E1E2E
mark2_background #CBA6F7
mark3_foreground #1E1E2E
mark3_background #74C7EC

# The basic colors
color0 #45475A
color1 #F38BA8
color2 #A6E3A1
color3 #F9E2AF
color4 #89B4FA
color5 #F5C2E7
color6 #94E2D5
color7 #BAC2DE
color8 #585B70
color9 #F38BA8
color10 #A6E3A1
color11 #F9E2AF
color12 #89B4FA
color13 #F5C2E7
color14 #94E2D5
color15 #A6ADC8
EOF
    }
    
    log "Kitty configuration created"
}

# Create Waybar config
create_waybar_config() {
    log "Creating Waybar configuration..."
    
    mkdir -p ~/.config/waybar
    
    cat << 'EOF' > ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["idle_inhibitor", "pulseaudio", "network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50
    },
    
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

    cat << 'EOF' > ~/.config/waybar/style.css
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono