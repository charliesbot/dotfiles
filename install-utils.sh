#!/usr/bin/env bash

# Shared utility functions for dotfiles installation

# Function to create temporary polkit rule to prevent graphical password dialogs
setup_polkit_nopasswd() {
    echo "Setting up polkit rule to prevent password dialogs..."
    # Use a pipe with echo instead of a here-document directly with sudo.
    # This is more robust and avoids potential hanging issues.
    echo 'polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/99-temporary-install.rules >/dev/null
    echo "Polkit rule created."
}

# Function to clean up temporary polkit rule
cleanup_polkit_rule() {
    sudo rm -f /etc/polkit-1/rules.d/99-temporary-install.rules
}

# Function to setup authentication for unattended installation
setup_unattended_auth() {
    echo "Configuring authentication for unattended installation..."

    # Create polkit rule
    setup_polkit_nopasswd

    # Start a background loop to keep sudo active.
    # This loop is started directly, avoiding subshell issues.
    while true; do
        sudo -n true
        sleep 30
    done 2>/dev/null &
    KEEPALIVE_PID=$!

    # Setup a trap to kill the background process and clean up the polkit rule on exit.
    # This now traps EXIT, INT (Ctrl+C), and TERM signals for more robust cleanup.
    trap "echo -e '\nCleaning up authentication helpers...'; kill $KEEPALIVE_PID &>/dev/null; cleanup_polkit_rule" EXIT INT TERM

    echo "Authentication configured. Sudo will stay active and no password dialogs will appear."
    echo
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

install_catpuccin_themes() {
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
}

# Install Homebrew
install_brew() {
    # 1. Check if brew is installed and log it
    if check_command brew; then
        echo "Homebrew is already installed."
    else
        # 2. If not installed, install it
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # 3. Follow Next steps instructions to add Homebrew to PATH
    echo "Setting up Homebrew environment..."

    # Source brew for current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Add to appropriate shell config based on current shell
    if [[ "$SHELL" == *"zsh" ]]; then
        echo "Adding Homebrew to ~/.zshrc"
        echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.zshrc
    else
        echo "Adding Homebrew to ~/.bashrc"
        echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.bashrc
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    echo "Removing existing dotfiles..."
    rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim ~/.ideavimrc ~/.config/starship.toml ~/config/ghostty 2>/dev/null

    echo "Creating symlinks..."
    mkdir -p ~/projects ~/.config ~/.config/tmux ~/.config/tmux/plugins

    ln -s ~/dotfiles/zshrc ~/.zshrc
    ln -s ~/dotfiles/nvim ~/.config/nvim
    ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
    ln -s ~/dotfiles/ghostty ~/.config/ghostty
    ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
    ln -s ~/dotfiles/ideavimrc ~/.ideavimrc

    # Italics and true color profile for tmux
    tic -x tmux.terminfo
}

# Install Starship prompt
install_starship() {
    echo "Installing Starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

# Install common brew packages
install_brew_packages() {
    brew update

    brew install jesseduffield/lazydocker/lazydocker # this is the tap for lazydocker
    brew install lazydocker                          # this is the actual package for lazy docker
    brew install neovim
    brew install zsh-autosuggestions
    brew install zsh-syntax-highlighting
    brew install nvm
    brew install devcontainer
    brew install scrcpy
    brew install tmux
    brew install gh
    brew install zig
    brew install lazygit
    brew install fnm
    brew install openjdk
    brew install zoxide

    if ! check_command fzf; then
        brew install fzf
        # Add FZF shortcuts non-interactively (enable all features)
        "$(brew --prefix)"/opt/fzf/install --all
    fi
}

# Setup ZSH as default shell
setup_zsh_shell() {
    # Check if the current shell is already zsh
    if [[ "$SHELL" == *"zsh" ]]; then
        echo "ZSH is the default shell."
    else
        # Get the path of zsh
        zsh_path=$(which zsh)

        # Change the default shell to zsh for future logins
        echo "Setting up zsh as your default shell..."
        if chsh -s "$zsh_path"; then
            echo "Setup complete. Log out and back in to start using zsh as your default shell."
        else
            echo "Error: Failed to change the default shell."
            echo "Please try running 'chsh -s $(which zsh)' manually."
        fi
    fi
}

# Install fonts for Linux
install_linux_fonts() {
    # Install Fonts
    mkdir -p ~/.local/share/fonts
    echo "Installing JetBrains Mono"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
    echo "Installing Cascadia"
    wget -qO- $(curl -s https://api.github.com/repos/microsoft/cascadia-code/releases/latest | grep browser_download_url | grep zip | cut -d '"' -f 4) -O cascadia.zip
    unzip -o cascadia.zip -d ~/.local/share/fonts
    rm cascadia.zip
    fc-cache -fv
}

# Configure DNS servers
configure_dns() {
    echo "Configuring DNS servers..."

    sudo mkdir -p /etc/systemd/resolved.conf.d
    echo -e "[Resolve]\nDNS=8.8.8.8 8.8.4.4\nFallbackDNS=1.1.1.1 1.0.0.1" | sudo tee /etc/systemd/resolved.conf.d/99-global-dns.conf >/dev/null
    sudo systemctl restart systemd-resolved

    echo "DNS configured with Google DNS (primary) and Cloudflare DNS (fallback)."
}

# Print completion message
print_completion() {
    echo -e "\n\n\n\nAll systems operational. 🤖"
    echo "                 "
    echo " ┓     ┓•   ┓    "
    echo "┏┣┓┏┓┏┓┃┓┏┓┏┣┓┏┓╋"
    echo "┗┛┗┗┻┛ ┗┗┗ ┛┗┛┗┛┗"
    echo "                 "
    echo "Your development environment is ready! Blast off!"
    echo ""
    echo "IMPORTANT: Please reboot or log out and back in to:"
    echo "  - Complete GPU driver installation"
    echo "  - Start using ZSH as your default shell"
}
