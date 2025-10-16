# ✨ Fedora Linux Automated Setup Script

<p align="center">
  <img src="https://fedoraproject.org/w/uploads/2/2d/Logo_fedoralogo.png" alt="Fedora Logo" width="200"/>
</p>

<div align="center">

[![Fedora](https://img.shields.io/badge/Fedora-42+-blue.svg?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Bash](https://img.shields.io/badge/bash-script-green.svg?style=for-the-badge&logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-brightgreen.svg?style=for-the-badge)](https://github.com/charliesbot/dotfiles/graphs/commit-activity)

</div>

---

## 👋 Hey there!

So you just installed Fedora and want to get up and running **fast**? This automated setup script handles all the tedious post-installation tasks for you. Instead of manually running dozens of commands and copying configs, just run this script and grab a coffee while it does the work.

This isn't some magical black box though. Everything it does is documented here, so you know exactly what's happening to your system.

### 🎯 What does this script do?

This script automates my entire Fedora post-installation workflow:

- ✅ Enables third-party repositories (RPM Fusion, Terra, Flathub)
- ✅ Installs essential development tools and packages
- ✅ Sets up GPU drivers (NVIDIA/AMD auto-detected)
- ✅ Installs multimedia codecs for video/audio playback
- ✅ Configures system services and firmware updates
- ✅ Installs and configures Homebrew package manager
- ✅ Sets up development tools (Node.js, VS Code, Android Studio)
- ✅ Installs applications (Chrome Beta, 1Password, Ghostty terminal)
- ✅ Configures dotfiles with symlinks
- ✅ Sets up ZSH shell with Starship prompt
- ✅ Configures laptop clamshell mode (lid switch behavior)
- ✅ Cleans up unwanted packages (like LibreOffice)

### 💡 Who's this for?

- ✅ **Fresh Fedora install?** Perfect use case.
- ✅ **Want a reproducible setup?** Absolutely.
- ✅ **Developer setting up a new machine?** You'll love this.
- ⚠️ **Just browsing and don't know bash?** Read the script first before running!

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [What Gets Installed](#-what-gets-installed)
- [Script Features](#-script-features)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)
- [Manual Steps](#-manual-steps)

---

## 🔧 Prerequisites

Before running this script, make sure:

- [ ] You're running **Fedora Linux** (41, 42, or newer)
- [ ] You have a **working internet connection**
- [ ] You're logged in as a user with **sudo privileges**
- [ ] You've cloned this repo to `~/dotfiles`

### Clone the repository:

```bash
cd ~
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
```

---

## 🚀 Quick Start

### Option 1: Run the full automated setup

This runs **everything** unattended:

```bash
cd ~/dotfiles/fedora
chmod +x install-fedora.sh
./install-fedora.sh
```

The script will:

1. Ask for your sudo password (keeps it alive during installation)
2. Prompt for hostname and Git configuration
3. Run all installation steps automatically
4. Reboot when finished (recommended)

> ⏱️ **Time estimate**: 30-60 minutes depending on your internet speed

---

### Option 2: Review before running (recommended for first-timers)

If you want to see what's happening before committing:

```bash
# Read the script first
less ~/dotfiles/fedora/install-fedora.sh

# Read the utility functions
less ~/dotfiles/install-utils.sh

# Run it when ready
cd ~/dotfiles/fedora
./install-fedora.sh
```

---

## 📦 What Gets Installed

### Repositories

- **RPM Fusion** (free & nonfree) - For codecs, drivers, and restricted software
- **Terra Repository** - Additional Fedora packages
- **Flathub** - Flatpak applications
- **Homebrew** - Cross-platform package manager

### System Packages

**Development Tools:**

- Git, curl, wget, zsh
- GCC, make, and development toolchain
- Neovim (via Homebrew)
- Lazygit, Lazydocker
- Tmux, fzf, zig

**Archive Tools:**

- p7zip, unrar

**Desktop Tools:**

- GNOME Tweaks
- Ghostty terminal emulator

**Virtualization:**

- KVM/QEMU for Android Emulator

### Applications

**Browsers:**

- Google Chrome Beta

**Development:**

- Visual Studio Code
- Android Studio (2025.1.3.7)

**Utilities:**

- 1Password
- Starship prompt

**AI Tools:**

- Google Gemini CLI
- Anthropic Claude Code CLI

### GPU Drivers

The script auto-detects your GPU:

**NVIDIA:**

- `akmod-nvidia` - Kernel module (auto-rebuilds on kernel updates)
- `xorg-x11-drv-nvidia-cuda` - CUDA support

**AMD:**

- `mesa-va-drivers-freeworld` - Video acceleration
- `mesa-vdpau-drivers-freeworld` - VDPAU support

### Multimedia Codecs

- Full FFmpeg (replaces ffmpeg-free)
- GStreamer plugins (base, good, bad, ugly)
- OpenH264 for Firefox
- Hardware video acceleration (VA-API)

### Fonts

- JetBrains Mono (installed to `~/.local/share/fonts`)
- Cascadia Code (installed to `~/.local/share/fonts`)

---

## ✨ Script Features

### Unattended Installation

The script uses a clever authentication setup to prevent password prompts:

```bash
# From install-utils.sh
setup_unattended_auth() {
    # Creates temporary polkit rule for passwordless sudo
    # Keeps sudo alive in background
    # Cleans up automatically when done
}
```

This means you enter your password **once** at the start, and the script handles everything else.

### GPU Auto-Detection

The script detects your GPU automatically:

```bash
if lspci | grep -i nvidia >/dev/null; then
    # Install NVIDIA drivers
elif lspci | grep -i amd >/dev/null; then
    # Install AMD drivers
else
    # Skip GPU driver installation
fi
```

### Firmware Updates

Updates all available firmware automatically:

```bash
sudo fwupdmgr refresh --force
sudo fwupdmgr update --assume-yes
```

### Clamshell Mode Configuration

Configures lid switch behavior for laptop docking:

```bash
# Allows laptop to stay on with lid closed when connected to external display
configure_lid_switch() {
    # Creates /etc/systemd/logind.conf.d/logind.conf
    # Sets HandleLidSwitch=ignore
}
```

### Dotfiles Symlink Creation

Automatically creates symlinks for all dotfiles:

```bash
~/.zshrc → ~/dotfiles/zshrc
~/.config/nvim → ~/dotfiles/nvim
~/.tmux.conf → ~/dotfiles/tmux.conf
~/.config/ghostty → ~/dotfiles/ghostty
~/.config/starship.toml → ~/dotfiles/starship.toml
~/.ideavimrc → ~/dotfiles/ideavimrc
```

---

## 🎨 Customization

### Disable specific installation steps

Open `install-fedora.sh` and comment out functions in `setup_fedora()`:

```bash
setup_fedora() {
    # ...
    # install_android_studio  # Comment this to skip Android Studio
    # install_chrome          # Comment this to skip Chrome
    install_vscode            # Keep this line to install VS Code
    # ...
}
```

### Change Android Studio version

Edit the version in `install_android_studio()`:

```bash
install_android_studio() {
    cd /tmp
    # Change version number here:
    wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.1.3.7/android-studio-2025.1.3.7-linux.tar.gz
    # ...
}
```

### Add custom packages

Add your packages to `install_fedora_packages()`:

```bash
install_fedora_packages() {
    # ...existing packages...

    # Add your custom packages here:
    sudo dnf install -y htop btop neofetch
}
```

### Modify Homebrew packages

Edit `install_brew_packages()` in `install-utils.sh`:

```bash
install_brew_packages() {
    brew install neovim
    brew install tmux
    # Add your packages:
    brew install bat exa ripgrep
}
```

---

## 🔍 Troubleshooting

### Script fails with permission errors

Make sure the script is executable:

```bash
chmod +x ~/dotfiles/fedora/install-fedora.sh
```

### NVIDIA driver not loading

Check if the kernel module built successfully:

```bash
modinfo -F version nvidia
```

If it returns nothing:

```bash
# Wait 5 minutes for module to build
sudo journalctl -f -u akmods

# Or force rebuild
sudo akmods --force --kernels $(uname -r)
sudo reboot
```

### Homebrew not in PATH after installation

Source your shell config:

```bash
# For bash
source ~/.bashrc

# For zsh
source ~/.zshrc

# Or restart your terminal
```

### Node.js tools not installing

Make sure fnm (Fast Node Manager) is installed and in PATH:

```bash
fnm --version

# If not found, reinstall via Homebrew
brew install fnm
```

### Symlinks not created

The script expects to be run from a repo cloned at `~/dotfiles`:

```bash
# Check current location
pwd

# Should output: /home/yourusername/dotfiles/fedora

# If not, clone to correct location:
cd ~
git clone https://github.com/yourusername/dotfiles.git
```

### Polkit password dialogs still appearing

The script creates a temporary polkit rule that should prevent dialogs. If you still see them:

```bash
# Check if rule exists
ls -la /etc/polkit-1/rules.d/99-temporary-install.rules

# Manually create if missing
sudo tee /etc/polkit-1/rules.d/99-temporary-install.rules >/dev/null <<'EOF'
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF
```

---

## 📝 Manual Steps

Some things still need manual configuration after the script runs:

### 1. Configure 1Password

```bash
# Launch 1Password
1password
# Sign in with your account
```

### 2. Configure Git signing (optional)

```bash
# If using GPG signing for commits
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_KEY_ID
```

### 3. Install GNOME Extensions

The script installs Extension Manager, but you need to manually install extensions:

```bash
flatpak run com.mattjakeman.ExtensionManager
```

Recommended extensions:

- Vitals
- Blur my Shell
- Dash to Dock

### 4. Configure VS Code settings sync

Open VS Code and sign in to sync your settings:

```bash
code
# Settings → Turn on Settings Sync
```

### 5. Set up Android Studio

```bash
# Launch Android Studio
/opt/android-studio/bin/studio

# Follow setup wizard to:
# - Download SDK components
# - Configure Android Virtual Devices
# - Set up JDK path
```

### 6. Reboot

After everything completes, reboot to ensure:

- GPU drivers load correctly
- ZSH becomes default shell
- All system changes take effect

```bash
sudo reboot
```

---

## 🔐 Security Notes

### Temporary polkit rule

The script creates a temporary polkit rule (`/etc/polkit-1/rules.d/99-temporary-install.rules`) that allows passwordless sudo for wheel group members.

**This is automatically cleaned up** when the script exits, but if the script is interrupted:

```bash
# Manually remove the rule
sudo rm -f /etc/polkit-1/rules.d/99-temporary-install.rules
```

### Sudo keep-alive

The script runs a background process to keep sudo alive. This is killed automatically, but if needed:

```bash
# Find the process
ps aux | grep "sudo -n true"

# Kill it
kill <PID>
```

---

## 📚 Script Architecture

The installation is split into two files:

### `install-fedora.sh`

- Main Fedora-specific setup
- Package installation functions
- Application installers
- GPU driver setup
- Main orchestration function

### `install-utils.sh`

- Shared utility functions
- Homebrew setup
- Dotfiles symlink creation
- Shell configuration
- Cross-distro compatible functions

This modular approach makes it easier to:

- Add support for other distros (just create `ubuntu/install-ubuntu.sh`)
- Share common functionality
- Maintain and debug individual components

---

## 🤝 Contributing

Found a bug? Want to add a feature? PRs welcome!

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🙏 Acknowledgments

This setup was heavily inspired by [wz790's Fedora Noble Setup Guide](https://github.com/wz790/Fedora-Noble-Setup). Big thanks for the comprehensive documentation and ideas that helped shape this automated installation script!

---

## 📄 License

This is free and unencumbered software released into the public domain. Do whatever you want with it.

---

## ⚠️ Disclaimer

This script modifies system configuration and installs software. While tested on my machines, **use at your own risk**. Always review scripts before running them with sudo privileges.

**Backup your important data before running this script.**

---

<div align="center">

**Made with ☕ and 🎵**

_Enjoy your automated Fedora setup!_

</div>
