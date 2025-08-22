Arch Linux Hyprland Installation Script

A comprehensive installation script for setting up Arch Linux with Hyprland window manager and essential applications.
🚀 Features

    Complete Hyprland Setup: Installs Hyprland with Wayland support
    Graphics Support: AMD, Intel, and NVIDIA graphics drivers
    Audio System: PipeWire with full audio stack
    Development Tools: Optional installation of coding tools
    Essential Applications: Browser, file manager, terminal, and utilities
    Automated Configuration: Sets up services and basic Hyprland config
    Interactive Installation: Prompts for hardware-specific choices

📋 What's Included
Core Components

    Hyprland window manager
    Wayland and XWayland support
    SDDM display manager
    PipeWire audio system

Applications

    Terminals: Kitty, Alacritty
    Shell: Zsh with Oh My Zsh
    Browser: Firefox, Chromium
    File Manager: Thunar with plugins
    Screenshots: Grim, Slurp, Swappy
    App Launcher: Rofi (Wayland)
    Status Bar: Waybar
    Notifications: Dunst

Development Tools (Optional)

    Visual Studio Code
    Git and GitHub CLI
    Node.js and npm
    Python and pip
    Docker and Docker Compose

🔧 Prerequisites

    Fresh Arch Linux installation
    Internet connection
    Non-root user account with sudo privileges

📥 Installation

    Clone the repository:
    bash

    git clone https://github.com/YOUR_USERNAME/arch-hyprland-install.git
    cd arch-hyprland-install

    Make the script executable:
    bash

    chmod +x install-hyprland.sh

    Run the installation:
    bash

    ./install-hyprland.sh

    Follow the prompts for hardware-specific options
    Reboot after completion:
    bash

    sudo reboot

⌨️ Default Keybindings

Key Combination	Action
Super + Return	Open terminal (Kitty)
Super + Q	Close active window
Super + M	Exit Hyprland
Super + E	Open file manager
Super + R	Open application launcher
Super + V	Toggle floating mode
Super + 1-0	Switch to workspace 1-10
Super + Shift + 1-0	Move window to workspace 1-10
Print	Screenshot area to clipboard
Super + Print	Screenshot full screen to clipboard

🎨 Customization

After installation, you can customize your setup:

    Hyprland config: ~/.config/hypr/hyprland.conf
    Waybar config: ~/.config/waybar/
    Rofi themes: ~/.config/rofi/
    Terminal config: ~/.config/kitty/ or ~/.config/alacritty/

🔧 Post-Installation

    Set up wallpaper:
    bash

    swww img /path/to/your/wallpaper.jpg

    Configure Waybar (optional):
    bash

    mkdir -p ~/.config/waybar
    # Add your waybar configuration

    Install additional themes from the AUR:
    bash

    yay -S gtk-theme-name icon-theme-name

🐛 Troubleshooting
Common Issues

NVIDIA Graphics Issues:

    Make sure to answer "yes" when prompted about NVIDIA graphics
    You may need to add nvidia_drm.modeset=1 to your kernel parameters

Audio Not Working:

    Restart audio services: systemctl --user restart pipewire pipewire-pulse
    Check audio devices: pactl list sinks

Hyprland Won't Start:

    Check logs: journalctl -u sddm
    Try starting from TTY: Hyprland

Screen Tearing:

    Add to Hyprland config: misc { vfr = true }

🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

    Fork the repository
    Create your feature branch: git checkout -b feature/amazing-feature
    Commit your changes: git commit -m 'Add some amazing feature'
    Push to the branch: git push origin feature/amazing-feature
    Open a pull request

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
🙏 Acknowledgments

    Hyprland - Amazing Wayland compositor
    Arch Linux - The best Linux distribution
    The open-source community for all the amazing tools

📞 Support

If you encounter any issues or have questions:

    Check the Issues page
    Create a new issue with detailed information
    Include system information and error logs

⚠️ Disclaimer: This script modifies your system significantly. Always backup your data before running installation scripts. Use at your own risk.

