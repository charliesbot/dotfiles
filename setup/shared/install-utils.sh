#!/usr/bin/env bash

set -euo pipefail

# Shared utility functions for dotfiles installation

POLKIT_RULE_FILE="/etc/polkit-1/rules.d/99-temporary-dotfiles-install.rules"

# Function to create temporary polkit rule to prevent graphical password dialogs
setup_polkit_nopasswd() {
  echo "Temporarily allowing passwordless polkit actions during setup..."
  sudo rm -f "$POLKIT_RULE_FILE"
  echo 'polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});' | sudo tee "$POLKIT_RULE_FILE" >/dev/null
  echo "Temporary polkit rule created."
}

# Function to clean up temporary polkit rule
cleanup_polkit_rule() {
  sudo rm -f "$POLKIT_RULE_FILE"
}

# Function to setup authentication for unattended installation
setup_unattended_auth() {
  echo "Configuring authentication for unattended installation..."

  setup_polkit_nopasswd

  start_sudo_keepalive

  trap "echo -e '\nCleaning up authentication helpers...'; kill $KEEPALIVE_PID &>/dev/null; cleanup_polkit_rule" EXIT INT TERM

  echo "Authentication configured. Sudo will stay active and no password dialogs will appear."
  echo
}

# Refresh sudo authentication
refresh_sudo() {
  sudo -v
}

# Keep sudo authentication active for long-running setup phases
start_sudo_keepalive() {
  while true; do
    sudo -n true
    sleep 30
  done 2>/dev/null &
  KEEPALIVE_PID=$!
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

# Prompt for VCS user details to be applied later
prompt_for_vcs_config() {
  echo "Enter your details for VCS configuration."
  read -p "Enter your full name: " vcs_name
  read -p "Enter your email: " vcs_email

  export VCS_CONFIG_NAME="$vcs_name"
  export VCS_CONFIG_EMAIL="$vcs_email"
}

# Apply stored VCS configuration
apply_vcs_config() {
  if [[ -n "${VCS_CONFIG_NAME:-}" && -n "${VCS_CONFIG_EMAIL:-}" ]]; then
    echo "Applying VCS configuration..."
    git config --global user.name "${VCS_CONFIG_NAME}"
    git config --global user.email "${VCS_CONFIG_EMAIL}"
    git config --global init.defaultBranch main
    echo "VCS user name and email have been set."
  else
    echo "VCS user details not provided, skipping VCS configuration."
  fi
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

}

# Create symlinks for dotfiles
create_symlinks() {
  local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"

  echo "Replacing existing configs with dotfiles..."
  rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim ~/.ideavimrc ~/.config/starship.toml ~/.config/ghostty ~/.config/herdr/config.toml ~/chai.toml 2>/dev/null

  echo "Creating symlinks..."
  mkdir -p ~/projects ~/.config ~/.config/herdr

  ln -s "$dotfiles_dir/config/zshrc" ~/.zshrc
  ln -s "$dotfiles_dir/config/nvim" ~/.config/nvim
  ln -s "$dotfiles_dir/config/ghostty" ~/.config/ghostty
  ln -s "$dotfiles_dir/config/herdr.toml" ~/.config/herdr/config.toml
  ln -s "$dotfiles_dir/config/starship.toml" ~/.config/starship.toml
  ln -s "$dotfiles_dir/config/ideavimrc" ~/.ideavimrc
  ln -s "$dotfiles_dir/config/chai.toml" ~/chai.toml
}

# Install common brew packages
install_brew_packages() {
  refresh_sudo
  brew update

  brew install \
    jesseduffield/lazydocker/lazydocker \
    lazygit \
    neovim \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    starship \
    devcontainer \
    scrcpy \
    gh \
    go \
    node \
    pnpm \
    fd \
    ripgrep \
    tree-sitter \
    fzf

  # Install fonts
  brew install --cask \
    font-jetbrains-mono \
    font-cascadia-code
}

# Install AI CLI tools
install_ai_tools() {
  echo "Installing AI CLI tools..."

  # Claude Code (native installer, auto-updates)
  if check_command claude; then
    echo "Claude Code is already installed."
  else
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # OpenCode
  if check_command opencode; then
    echo "OpenCode is already installed."
  else
    curl -fsSL https://opencode.ai/install | bash
  fi

  # Ollama
  if check_command ollama; then
    echo "Ollama is already installed."
  else
    curl -fsSL https://ollama.com/install.sh | sh
  fi

  # Antigravity CLI
  if check_command antigravity; then
    echo "Antigravity CLI is already installed."
  else
    curl -fsSL https://antigravity.google/cli/install.sh | bash
  fi

  echo "AI CLI tools installed."
}

# Install Android CLI
install_android_cli() {
  if check_command android; then
    echo "Android CLI is already installed."
    return
  fi

  echo "Installing Android CLI..."

  if [[ "$(uname)" == "Darwin" ]]; then
    curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh | bash
  else
    curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install.sh | bash
  fi

  echo "Android CLI installed."
}

# Setup ZSH as default shell
setup_zsh_shell() {
  if [[ "${SHELL:-}" == *"zsh" ]]; then
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
