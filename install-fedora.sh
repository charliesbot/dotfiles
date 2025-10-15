#!/usr/bin/env bash

# Fedora-specific dotfiles installation script

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the shared utilities
source "$SCRIPT_DIR/install-utils.sh"

# Enable third-party repositories
enable_third_party_repos() {
    echo "Enabling third-party repositories..."

    # Enable RPM Fusion repositories
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Enable Terra repository
    sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

    # Install app-stream metadata
    sudo dnf group upgrade -y core
    sudo dnf4 group install -y core

    # Remove the limited Fedora repo
    flatpak remote-delete --system fedora --force 2>/dev/null || true

    # Enable Flathub repository
    flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak update --system --appstream -y --noninteractive

    echo "Third-party repositories enabled."
}

# Fedora-specific package installation
install_fedora_packages() {
    echo "Installing Fedora packages..."

    # Update OS
    sudo dnf upgrade -y

    # Install basic development tools
    sudo dnf install -y zsh curl wget git
    sudo dnf group install -y development-tools
    sudo dnf install -y procps-ng curl file
    sudo dnf5 install @development-tools -y

    # Install archive tools
    sudo dnf install -y p7zip p7zip-plugins unrar

    # Install Ghostty terminal emulator
    sudo dnf install -y ghostty

    # Enable KVM for Android Emulator
    sudo dnf5 install @virtualization -y
    sudo usermod -aG kvm $(whoami)
}

# Install Android Studio
install_android_studio() {
    echo "Installing Android Studio..."

    # Download Android Studio
    cd /tmp
    wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.1.3.7/android-studio-2025.1.3.7-linux.tar.gz

    # Extract to /opt
    sudo tar -xzf android-studio-2025.1.3.7-linux.tar.gz -C /opt/

    # Clean up
    rm android-studio-2025.1.3.7-linux.tar.gz

    echo "Android Studio installed to /opt/android-studio/"
    echo "You can run it with: /opt/android-studio/bin/studio"
}

# Install Google Chrome Beta
install_chrome() {
    echo "Installing Google Chrome Beta..."

    # Download Chrome Beta RPM
    cd /tmp
    wget https://dl.google.com/linux/direct/google-chrome-beta_current_x86_64.rpm

    # Install Chrome Beta
    sudo dnf install -y google-chrome-beta_current_x86_64.rpm

    # Clean up
    rm google-chrome-beta_current_x86_64.rpm

    echo "Google Chrome Beta installed."
}

# Install Visual Studio Code
install_vscode() {
    echo "Installing Visual Studio Code..."

    # Import Microsoft GPG key
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    # Add VS Code repository to system packages
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    # Install VS Code
    sudo dnf install -y code

    echo "Visual Studio Code installed."
}

# Install 1Password
install_1password() {
    echo "Installing 1Password..."

    # Add the key for the 1Password yum repository
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc

    # Add the 1Password yum repository
    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'

    # Install 1Password
    sudo dnf install -y 1password

    echo "1Password installed."
}

# Install Node.js and AI CLI tools
install_node_and_tools() {
    echo "Installing Node.js using fnm..."

    # Setup fnm environment for current bash session
    if command -v fnm &>/dev/null; then
        eval "$(fnm env --use-on-cd --shell bash)"

        # Install the latest Node.js version using fnm
        fnm install latest
        fnm use latest
        fnm default latest

        echo "Installing AI CLI tools..."
        # Install Google Gemini CLI
        npm install -g @google/gemini-cli
        # Install Anthropic Claude Code CLI
        npm install -g @anthropic-ai/claude-code

        echo "Node.js and AI CLI tools installed."
    else
        echo "fnm not found. Skipping Node.js installation."
        echo "Note: fnm should have been installed via Homebrew."
    fi
}

# Install GPU drivers
install_gpu_drivers() {
    echo "Detecting GPU and installing appropriate drivers..."

    # Check for NVIDIA GPU
    if lspci | grep -i nvidia >/dev/null; then
        echo "NVIDIA GPU detected. Installing NVIDIA drivers..."
        sudo dnf update -y
        sudo dnf install -y akmod-nvidia
        sudo dnf install -y xorg-x11-drv-nvidia-cuda

        echo "NVIDIA drivers installed. Checking kernel module..."
        echo "Waiting 5 minutes for kernel module to build..."
        sleep 300

        if modinfo -F version nvidia 2>/dev/null; then
            echo "NVIDIA kernel module built successfully."
        else
            echo "NVIDIA kernel module not ready yet. Check 'modinfo -F version nvidia' after reboot."
        fi

        echo "NVIDIA setup complete. Reboot recommended."

    # Check for AMD GPU
    elif lspci | grep -i amd >/dev/null || lspci | grep -i radeon >/dev/null; then
        echo "AMD GPU detected. Installing AMD drivers..."
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
        sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 || echo "32-bit mesa-va-drivers not found, skipping"
        sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 || echo "32-bit mesa-vdpau-drivers not found, skipping"
        echo "AMD drivers installed."

    else
        echo "No NVIDIA or AMD GPU detected, skipping GPU driver installation."
    fi
}

# Update firmware
update_firmware() {
    echo "Updating firmware..."

    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-devices # Lists devices with available updates
    sudo fwupdmgr get-updates # Fetches list of available updates
    sudo fwupdmgr update --assume-yes || echo "No firmware updates available or update failed"

    echo "Firmware update completed."
}

# Install multimedia codecs and packages
install_multimedia() {
    echo "Installing multimedia codecs and packages..."

    sudo dnf4 group install -y multimedia
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing                                                   # Switch to full FFMPEG
    sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications
    sudo dnf group install -y sound-and-video                                                                # Installs useful Sound and Video complementary packages
    sudo dnf install -y ffmpeg-libs libva libva-utils
    sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

    echo "Multimedia packages installed."
}

# Configure system services
configure_services() {
    echo "Configuring system services..."

    sudo systemctl disable NetworkManager-wait-online.service

    echo "System services configured."
}

# Configure lid switch behavior to allow clamshell mode
configure_lid_switch() {
    echo "Configuring lid switch behavior for clamshell mode..."

    local config_file="/etc/systemd/logind.conf.d/logind.conf"

    # Create the directory if it doesn't exist
    sudo mkdir -p "$(dirname "$config_file")"

    # Write the configuration using a heredoc
    sudo tee "$config_file" >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

    # Restart the service to apply changes
    sudo systemctl restart systemd-logind.service

    echo "Lid switch behavior configured."
}

# Set hostname
set_hostname() {
    echo "Current hostname: $(hostnamectl --static)"
    read -p "Enter new hostname (or press Enter to keep current): " new_hostname

    if [[ -n "$new_hostname" ]]; then
        sudo hostnamectl set-hostname "$new_hostname"
        echo "Hostname set to: $new_hostname"
    else
        echo "Keeping current hostname."
    fi
}

# Cleanup unwanted packages
cleanup_packages() {
    echo "Cleaning up unwanted packages..."

    # Remove LibreOffice completely (quote the wildcard for zsh compatibility)
    sudo dnf remove -y "libreoffice*"

    # Clean up orphaned packages
    sudo dnf autoremove -y

    echo "Package cleanup completed."
}

# Main setup function for Fedora
setup_fedora() {
    echo -e "Setting up dotfiles for Fedora...\n"

    # Set hostname
    set_hostname

    # Configure DNS servers
    configure_dns

    # Update firmware
    update_firmware

    # Enable third-party repositories
    enable_third_party_repos

    # Install Fedora-specific packages
    install_fedora_packages

    # Install multimedia codecs and packages
    install_multimedia

    # Install GPU drivers
    install_gpu_drivers

    # Configure system services
    configure_services

    # Configure lid switch for clamshell mode
    configure_lid_switch

    # Install Homebrew and packages (before changing shell)
    install_brew
    install_starship
    install_brew_packages

    # Install Node.js and global npm packages (after brew packages which includes fnm)
    install_node_and_tools

    # Install Android Studio
    install_android_studio

    # Install Google Chrome Beta
    install_chrome

    # Install Visual Studio Code
    install_vscode

    # Install 1Password
    install_1password

    # Install fonts
    install_linux_fonts

    # Cleanup unwanted packages
    cleanup_packages

    # Create dotfile symlinks (this will overwrite .bashrc)
    create_symlinks

    # Install Catpuccin Themes (Tmux)
    install_catpuccin_themes

    # Setup ZSH as default shell (last step)
    setup_zsh_shell

    # Print completion message
    print_completion

    # Clean up temporary sudoers configuration
    sudo rm -f /etc/sudoers.d/install_timeout
}

# Detect OS and run setup
os_type="$(uname)"
if [[ "$os_type" != "Linux" ]]; then
    echo "This script is designed for Fedora Linux only."
    echo "Detected OS: $os_type"
    exit 1
fi

# Check if running on Fedora
if ! command -v dnf &>/dev/null; then
    echo "This script requires dnf package manager (Fedora)."
    exit 1
fi

echo "Fedora detected. Starting installation..."

# Ask for the administrator password upfront
sudo -v

# Extend sudo timeout to 30 minutes for this session
sudo sh -c 'echo "Defaults:$SUDO_USER timestamp_timeout=30" > /etc/sudoers.d/install_timeout'

# Disable GUI password prompts by preferring terminal authentication
export SUDO_ASKPASS=/bin/false

# Keep sudo alive during the long installation process
keep_sudo_alive

# Run the main setup
setup_fedora
