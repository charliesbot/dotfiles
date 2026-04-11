#!/usr/bin/env bash

# Shared utility functions for dotfiles installation

# Function to create temporary polkit rule to prevent graphical password dialogs
setup_polkit_nopasswd() {
    echo "Setting up polkit rule to prevent password dialogs..."
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

    setup_polkit_nopasswd

    while true; do
        sudo -n true
        sleep 30
    done 2>/dev/null &
    KEEPALIVE_PID=$!

    trap "echo -e '\nCleaning up authentication helpers...'; kill $KEEPALIVE_PID &>/dev/null; cleanup_polkit_rule" EXIT INT TERM

    echo "Authentication configured. Sudo will stay active and no password dialogs will appear."
    echo
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

# Suppress login message
suppress_login_message() {
    echo "Suppressing login message..."
    touch ~/.hushlogin
    echo "Login message suppressed."
}

# Prompt for Git user details to be applied later
prompt_for_git_config() {
    echo "Enter your details for Git configuration."
    read -p "Enter your full name: " git_name
    read -p "Enter your email: " git_email

    export GIT_CONFIG_NAME="$git_name"
    export GIT_CONFIG_EMAIL="$git_email"
}

# Apply stored Git configuration
apply_git_config() {
    if [[ -n "$GIT_CONFIG_NAME" && -n "$GIT_CONFIG_EMAIL" ]]; then
        echo "Applying Git configuration..."
        git config --global user.name "$GIT_CONFIG_NAME"
        git config --global user.email "$GIT_CONFIG_EMAIL"
        echo "Git user name and email have been set."
    else
        echo "Git user details not provided, skipping Git configuration."
    fi
}

install_catpuccin_themes() {
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
}

# Install Homebrew
install_brew() {
    if check_command brew; then
        echo "Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Setting up Homebrew environment..."

    if [[ "$(uname)" == "Darwin" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    # brew shellenv is already in config/zshrc — only append for non-zsh shells
    if [[ "$SHELL" != *"zsh" ]]; then
        grep -q "brew shellenv" ~/.bashrc 2>/dev/null || echo 'eval "$(brew shellenv)"' >>~/.bashrc
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    echo "Removing existing dotfiles..."
    rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim ~/.ideavimrc ~/.config/starship.toml ~/.config/ghostty 2>/dev/null

    echo "Creating symlinks..."
    mkdir -p ~/projects ~/.config ~/.config/tmux ~/.config/tmux/plugins

    ln -s ~/dotfiles/config/zshrc ~/.zshrc
    ln -s ~/dotfiles/config/nvim ~/.config/nvim
    ln -s ~/dotfiles/config/tmux.conf ~/.tmux.conf
    ln -s ~/dotfiles/config/ghostty ~/.config/ghostty
    ln -s ~/dotfiles/config/starship.toml ~/.config/starship.toml
    ln -s ~/dotfiles/config/ideavimrc ~/.ideavimrc

    # Italics and true color profile for tmux
    tic -x ~/dotfiles/config/tmux.terminfo
}

# Install common brew packages
install_brew_packages() {
    brew update

    brew install jesseduffield/lazydocker/lazydocker
    brew install neovim
    brew install tree-sitter-cli
    brew install zoxide
    brew install zsh-autosuggestions
    brew install zsh-syntax-highlighting
    brew install starship
    brew install devcontainer
    brew install scrcpy
    brew install tmux
    brew install gh
    brew install zig
    brew install go
    brew install lazygit

    # Install fonts
    brew install --cask font-jetbrains-mono
    brew install --cask font-cascadia-code

    if ! check_command fzf; then
        brew install fzf
    fi
}

# Install Bun
install_bun() {
    if check_command bun; then
        echo "Bun is already installed."
    else
        echo "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
}

# Install AI CLI tools
install_ai_tools() {
    echo "Installing AI CLI tools..."

    # Claude Code (native installer, auto-updates)
    curl -fsSL https://claude.ai/install.sh | bash

    # OpenCode
    curl -fsSL https://opencode.ai/install | bash

    # Ollama
    curl -fsSL https://ollama.com/install.sh | sh

    # Gemini CLI (via Bun)
    bun install -g @google/gemini-cli

    echo "AI CLI tools installed."
}

# Setup ZSH as default shell
setup_zsh_shell() {
    if [[ "$SHELL" == *"zsh" ]]; then
        echo "ZSH is the default shell."
    else
        zsh_path=$(which zsh)

        echo "Setting up zsh as your default shell..."
        if chsh -s "$zsh_path"; then
            echo "Setup complete. Log out and back in to start using zsh as your default shell."
        else
            echo "Error: Failed to change the default shell."
            echo "Please try running 'chsh -s $(which zsh)' manually."
        fi
    fi
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
    echo -e "\n\n\n\nAll systems operational."
    echo "                 "
    echo " ┓     ┓•   ┓    "
    echo "┏┣┓┏┓┏┓┃┓┏┓┏┣┓┏┓╋"
    echo "┗┛┗┗┻┛ ┗┗┗ ┛┗┛┗┛┗"
    echo "                 "
    echo "Your development environment is ready! Blast off!"
}
