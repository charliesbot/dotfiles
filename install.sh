#!/usr/bin/env bash

# Function to keep updating the sudo timestamp until the script ends
keep_sudo_alive() {
    while true; do sudo -n true; sleep 60; done 2>/dev/null &
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    command -v "$cmd" &> /dev/null
}

mac_configs() {
# disable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
# Keyboard: enable full keyboard access for all controls (e.g. enable
# Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Keyboard: set key repeat speed
defaults write NSGlobalDomain KeyRepeat -int 2
# Keyboard: set delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 25
# Window Manager: disable margins of tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
# Dock: only show when moving pointer to the screen edge
defaults write com.apple.dock autohide -bool true
# Dock: don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Dock: group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool true
# Dock: disable all Hot Corners
#
# wvous-C-corner: action associated with the corner; 0 for no-op
#
# wvous-C-modifier: modifier keys (as a bit mask) which need to be
# pressed for the hot corner to trigger; 0 for no modifier
#
# Where C signifies corner: bottom-left (bl), bottom-right (br),
# top-left (tl), and top-right (tr)
#
# See
# https://blog.jiayu.co/2018/12/quickly-configuring-hot-corners-on-macos/
disable_dock_hot_corners() {
    local corner
    local corners=(bl br tl tr)

    for corner in "${corners[@]}"; do
        defaults write com.apple.dock "wvous-$corner-corner" -int 0
        defaults write com.apple.dock "wvous-$corner-modifier" -int 0
    done
}

disable_dock_hot_corners
}

install_brew() {
	if ! check_command brew; then
		echo "Installing Brew..."
	    	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		if [[ $os_type == "Linux" ]]; then
			echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi
	fi
}

create_symlinks() {
    echo "Removing existing dotfiles..."
    rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim ~/.ideavimrc ~/.wezterm.lua ~/.config/starship.toml	2>/dev/null

    echo "Creating symlinks..."
    mkdir -p ~/.config/nvim
    mkdir -p ~/projects

    ln -s ~/dotfiles/zshrc ~/.zshrc
    ln -s ~/dotfiles/nvim ~/.config/nvim
    ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
    ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
    ln -s ~/dotfiles/ideavimrc ~/.ideavimrc
    ln -s ~/dotfiles/gitmux.conf ~/.gitmux.conf
}

install_starship() {
	echo "Installing Starship"
	curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_brew_packages() {
	brew update

	brew install jesseduffield/lazydocker/lazydocker # this is the tap for lazydocker
	brew install lazydocker # this is the actual package for lazy docker
	brew install neovim
	brew install tmux
	brew install tpm # tmux package manager
	brew install zsh-autosuggestions
	brew install zsh-syntax-highlighting
	brew install nvm
	brew install devcontainer
	brew install scrcpy
	brew install gh
	# Gitmux
	brew tap arl/arl
	brew install gitmux

	if ! check_command fzf; then
		brew install fzf
		# Add FZF shortcuts
		"$(brew --prefix)"/opt/fzf/install
	fi
}

install_brew_cask_packages() {
	brew install --cask 1password
	brew install --cask docker
	brew install --cask google-chrome
	brew install --cask logi-options+
	brew install --cask android-studio
	brew install --cask visual-studio-code
	brew install --cask raycast
	brew install --cask whatsapp
	brew install --cask ghostty
	brew install --cask ghostty
}

setup_linux() {
	echo -e "Using specific config for Linux \n"

	# update OS
	sudo dnf upgrade -y

	sudo dnf install -y zsh curl wget git

	create_symlinks

	# Italics and true color profile for tmux
	tic -x tmux.terminfo

	# Install Fonts
	mkdir -p ~/.local/share/fonts
	echo "Installing JetBrains Mono"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
	echo "Installing Cascadia"
	wget -qO- $(curl -s https://api.github.com/repos/microsoft/cascadia-code/releases/latest | grep browser_download_url | grep zip | cut -d '"' -f 4) -O cascadia.zip
	unzip -o cascadia.zip -d ~/.local/share/fonts
	rm cascadia.zip
	fc-cache -fv

	install_brew
	install_starship
	install_brew_packages

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

setup_mac() {
	echo -e "Using specific config for Mac \n"

	create_symlinks

	# Italics and true color profile for tmux
	tic -x tmux.terminfo

	install_starship

	mac_configs

	install_brew

	brew tap homebrew/cask-fonts

	# casks only work in mac
	echo "Installing Cascadia"
	brew install --cask font-cascadia
	echo "Installing JetBrains Mono"
	brew install --cask font-jetbrains-mono

	brew install reattach-to-user-namespace

	install_brew_packages
	install_brew_cask_packages
}

setup_bluefin() {
	echo -e "Using specific config for Bluefin \n"

	create_symlinks

	# Italics and true color profile for tmux
	tic -x tmux.terminfo

	install_brew_packages

	ujust shell zsh

	ujust dx-group # setup user and permissions for docker
}

os_type=""

if check_command ujust; then
    os_type="Bluefin"
elif [[ $(uname) == "Darwin" ]]; then
    os_type="Mac"
else
    os_type="Linux"
fi

echo -e "$os_type detected. Using $os_type config... \n"

# Ask for the administrator password upfront and keep the sudo timestamp updated
#sudo -v

# keep_sudo_alive

case $os_type in
    "Bluefin")
        setup_bluefin
        ;;
    "Mac")
        setup_mac
        ;;
    "Linux")
        setup_linux
        ;;
    *)
        echo "Unknown OS type: $os_type. Exiting."
        exit 1
        ;;
esac

echo -e "\n\n\n\nAll systems operational. 🤖"
echo "                 "
echo " ┓     ┓•   ┓    "
echo "┏┣┓┏┓┏┓┃┓┏┓┏┣┓┏┓╋"
echo "┗┛┗┗┻┛ ┗┗┗ ┛┗┛┗┛┗"
echo "                 "
echo "Your development environment is ready! Blast off!"
