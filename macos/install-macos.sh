#!/usr/bin/env bash

# macOS-specific dotfiles installation script

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the shared utilities
source "$SCRIPT_DIR/../install-utils.sh"

# Configure macOS system defaults
configure_macos_defaults() {
    echo "Configuring macOS system defaults..."

    # Keyboard: disable key repeat delay (enable key repeat instead of special characters)
    defaults write -g ApplePressAndHoldEnabled -bool false

    # Keyboard: enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Keyboard: set key repeat speed (fastest)
    defaults write NSGlobalDomain KeyRepeat -int 2

    # Keyboard: set delay until key repeat (shorter delay)
    defaults write NSGlobalDomain InitialKeyRepeat -int 25

    # Keyboard: set global key repeat speed to maximum (faster character repeat in all apps)
    defaults write -g KeyRepeat -int 1

    # Keyboard: set global initial key repeat delay to minimum (quicker response when holding keys)
    defaults write -g InitialKeyRepeat -int 10

    # Window Manager: disable margins of tiled windows
    defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

    # Dock: only show when moving pointer to the screen edge
    defaults write com.apple.dock autohide -bool true

    # Dock: don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Dock: group windows by application in Mission Control
    defaults write com.apple.dock expose-group-apps -bool true

    # Disable all Hot Corners
    disable_dock_hot_corners

    echo "macOS defaults configured. You may need to restart for some changes to take effect."
}

# Disable all Dock hot corners
disable_dock_hot_corners() {
    local corner
    local corners=(bl br tl tr)

    for corner in "${corners[@]}"; do
        defaults write com.apple.dock "wvous-$corner-corner" -int 0
        defaults write com.apple.dock "wvous-$corner-modifier" -int 0
    done
}

# Install macOS-specific packages via Homebrew cask
install_brew_cask_packages() {
    echo "Installing macOS applications via Homebrew Cask..."

    brew install --cask 1password
    brew install --cask docker
    brew install --cask google-chrome
    brew install --cask logi-options+
    brew install --cask jetbrains-toolbox
    brew install --cask visual-studio-code
    brew install --cask raycast
    brew install --cask whatsapp
    brew install --cask ghostty

    echo "Homebrew Cask applications installed."
    echo "Use JetBrains Toolbox to install Android Studio and other JetBrains IDEs."
}

# Install fonts via Homebrew
install_macos_fonts() {
    echo "Installing fonts..."

    # Install fonts
    echo "Installing Cascadia Code font..."
    brew install --cask font-cascadia-code

    echo "Installing JetBrains Mono font..."
    brew install --cask font-jetbrains-mono

    echo "Fonts installed."
}

# Install macOS-specific packages
install_macos_packages() {
    echo "Installing macOS-specific packages..."

    # Install reattach-to-user-namespace for tmux clipboard support on macOS
    brew install reattach-to-user-namespace

    echo "macOS-specific packages installed."
}

# Set computer name/hostname
set_hostname() {
    echo "Current computer name: $(scutil --get ComputerName 2>/dev/null || echo 'Not set')"
    echo "Current hostname: $(scutil --get HostName 2>/dev/null || echo 'Not set')"
    echo "Current local hostname: $(scutil --get LocalHostName 2>/dev/null || echo 'Not set')"

    read -p "Enter new computer name (or press Enter to keep current): " new_name

    if [[ -n "$new_name" ]]; then
        sudo scutil --set ComputerName "$new_name"
        sudo scutil --set HostName "$new_name"
        sudo scutil --set LocalHostName "$new_name"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$new_name"
        echo "Computer name set to: $new_name"
    else
        echo "Keeping current computer name."
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    echo "Checking for Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools already installed."
    else
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install

        echo "Please complete the Xcode Command Line Tools installation in the dialog that appeared."
        echo "Press Enter after the installation is complete..."
        read
    fi
}

# Main setup function for macOS
setup_macos() {
    echo -e "Setting up dotfiles for macOS...\\n"

    # Suppress login message
    suppress_login_message

    # Install Xcode Command Line Tools first (required for many tools)
    install_xcode_tools

    # Set computer name/hostname
    set_hostname

    # Prompt for Git details
    prompt_for_git_config

    # Configure macOS system defaults
    configure_macos_defaults

    # Install Homebrew (before anything else that needs it)
    install_brew

    # Install common brew packages from shared utilities
    install_brew_packages

    # Install macOS-specific packages
    install_macos_packages

    # Install macOS applications via Cask
    install_brew_cask_packages

    # Install fonts
    install_macos_fonts

    # Apply Git configuration
    apply_git_config

    # Install Node.js and global npm packages (after brew packages which includes fnm)
    install_node_and_tools

    # Create dotfile symlinks
    create_symlinks

    # Install Catppuccin Themes (Tmux)
    install_catpuccin_themes

    # Setup ZSH as default shell (last step)
    setup_zsh_shell

    # Print completion message
    print_completion
}

# Detect OS and run setup
os_type="$(uname)"
if [[ "$os_type" != "Darwin" ]]; then
    echo "This script is designed for macOS only."
    echo "Detected OS: $os_type"
    exit 1
fi

echo "macOS detected. Starting installation..."

# Ask for the administrator password upfront
sudo -v

# Keep sudo alive for the duration of the script
# (Note: macOS doesn't need the polkit setup that Linux does)
while true; do
    sudo -n true
    sleep 60
done 2>/dev/null &
KEEPALIVE_PID=$!

# Setup trap to kill the keepalive process on exit
trap "kill $KEEPALIVE_PID &>/dev/null" EXIT INT TERM

# Run the main setup
setup_macos
