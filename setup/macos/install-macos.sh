#!/usr/bin/env bash

set -euo pipefail

# macOS-specific dotfiles installation script

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Source the shared utilities
source "$SCRIPT_DIR/../shared/install-utils.sh"

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
    refresh_sudo

    echo "Installing macOS applications via Homebrew Cask..."

    brew install --cask \
        1password \
        docker \
        google-chrome \
        logi-options+ \
        jetbrains-toolbox \
        raycast \
        whatsapp \
        ghostty

    echo "Homebrew Cask applications installed."
    echo "Use JetBrains Toolbox to install Android Studio and other JetBrains IDEs."
}

# Install macOS-specific packages
install_macos_packages() {
    refresh_sudo

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
        local local_hostname
        local_hostname="$(printf "%s" "$new_name" | tr -cd '[:alnum:] -' | tr ' ' '-' | tr -s '-' | sed 's/^-*//; s/-*$//')"

        if [[ -z "$local_hostname" ]]; then
            echo "Error: Local hostname would be empty after sanitizing '$new_name'."
            return 1
        fi

        sudo scutil --set ComputerName "$new_name"
        sudo scutil --set HostName "$new_name"
        sudo scutil --set LocalHostName "$local_hostname"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$new_name"
        echo "Computer name set to: $new_name"
        echo "Local hostname set to: $local_hostname"
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

    suppress_login_message

    install_xcode_tools

    set_hostname

    prompt_for_vcs_config

    configure_macos_defaults

    install_brew

    install_brew_packages

    install_macos_packages

    install_brew_cask_packages

    install_android_cli

    apply_vcs_config

    install_ai_tools

    create_symlinks

    install_catpuccin_themes

    setup_zsh_shell

    setup_github_ssh

    print_completion
}

# Authenticate with GitHub and switch remote to SSH
setup_github_ssh() {
    if ! check_command gh; then
        echo "gh not found, skipping GitHub SSH setup."
        return
    fi

    if gh auth status &>/dev/null; then
        echo "Already authenticated with GitHub."
    else
        echo "Setting up GitHub authentication..."
        gh auth login --web --git-protocol ssh
    fi

    # Switch dotfiles remote from HTTPS to SSH if needed
    local remote_url
    remote_url=$(jj -R "$DOTFILES_DIR" git remote list | awk '$1 == "origin" { print $2 }')
    if [[ "$remote_url" == https://* ]]; then
        echo "Switching dotfiles remote to SSH..."
        jj -R "$DOTFILES_DIR" git remote set-url origin git@github.com:charliesbot/dotfiles.git
    fi
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
refresh_sudo

# Keep sudo alive for the duration of the script
start_sudo_keepalive

trap "kill $KEEPALIVE_PID &>/dev/null" EXIT INT TERM

setup_macos
