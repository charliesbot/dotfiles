#!/usr/bin/env bash
os_type=$(uname)

if [[ $os_type == "Darwin" ]]; then
    config_type="Mac"
else
    config_type="Linux"
fi

echo "$config_type detected. Using $config_type config..."

# Brew must be installed before any other step
echo "Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ $(uname) == "Linux" ]]; then
	sudo dnf upgrade -y
	sudo dnf install -y zsh curl wget git
	(
		echo
		echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
	) >>$HOME/.bashrc
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	echo "Switching to ZSH"
fi

echo "Installing Starship"
curl -sS https://starship.rs/install.sh | sh

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.config/nvim 2>/dev/null
rm -rf ~/.ideavimrc

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config/ ~/.config/nvim/

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/nvim/* ~/.config/nvim/
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
ln -s ~/dotfiles/wezterm.lua ~/.wezterm.lua
ln -s ~/dotfiles/ideavimrc ~/.ideavimrc

brew update

brew install zellij
brew install jesseduffield/lazydocker/lazydocker
brew install lazydocker
brew install neovim
brew install fzf
brew install nvm
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

if [[ $(uname) == "Linux" ]]; then
	mkdir -p ~/.local/share/fonts
	echo "Installing JetBrains Mono"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
	echo "Installing Cascadia"
	wget -qO- https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip -O cascadia.zip
	unzip -o cascadia.zip -d ~/.local/share/fonts
	rm cascadia.zip
	fc-cache -fv
	echo "Installing WezTerm"
	flatpak run org.wezfurlong.wezterm -y
fi

if [[ $(uname) == "Darwin" ]]; then
	echo "Using specific config for Mac"
	# disable key repeat
	defaults write -g ApplePressAndHoldEnabled -bool false

	brew tap homebrew/cask-fonts

	# casks only work in mac
	echo "Installing Cascadia"
	brew install --cask font-cascadia
	echo "Installing JetBrains Mono"
	brew install --cask font-jetbrains-mono

	brew install reattach-to-user-namespace
fi

# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# Writting vim will launch nvim
alias vim="nvim"

# Check if the current shell is already zsh
if [[ "$SHELL" == *"zsh" ]]; then
    echo "You are already using zsh as your default shell."
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

echo "All systems operational. 🤖"
echo " ┓     ┓•   ┓    "
echo "┏┣┓┏┓┏┓┃┓┏┓┏┣┓┏┓╋"
echo "┗┛┗┗┻┛ ┗┗┗ ┛┗┛┗┛┗"
echo "                 "
echo "Your development environment is ready! Blast off!"
