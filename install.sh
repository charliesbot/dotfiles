#!/usr/bin/env bash
if [[ $(uname) == "Darwin" ]]; then
	echo "Mac detected. Using Mac config..."
	curl -sS https://starship.rs/install.sh | sh
	echo "Installing brew"
	# install brew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ $(uname) == "Linux" ]]; then
	echo "Linux detected. Using Linux config..."
	echo "Bluefin already supports Starship."
	echo "Switching to ZSH"
fi

echo "Installing Kitty Snazzy Theme"
curl -o ~/.config/kitty/snazzy.conf https://raw.githubusercontent.com/connorholyday/kitty-snazzy/master/snazzy.conf

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2>/dev/null
rm -rf ~/.ideavimrc

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config/ ~/.config/nvim/

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/nvim/* ~/.config/nvim/
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
ln -s ~/dotfiles/wezterm.lua ~/.wezterm.lua
ln -s ~/dotfiles/ideavimrc ~/.ideavimrc

# Italics and true color profile for tmux
tic -x tmux.terminfo

brew update

brew install ripgrep
brew install tmux
brew install neovim
brew install ag
brew install fzf
brew install bat
brew install go
brew install llvm
brew install gcc
brew install gdb
brew install bazel
brew install cmake
brew install pyenv
brew install nvm
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

if [[ $(uname) == "Linux" ]]; then
	echo "Linux detected. Using Linux config..."
	echo "Installing JetBrains Mono"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
	flatpak run org.wezfurlong.wezterm -y
fi

if [[ $(uname) == "Darwin" ]]; then
	echo "Using specific config for Mac"
	# disable key repeat
	defaults write -g ApplePressAndHoldEnabled -bool false

	brew install starship

	brew tap homebrew/cask-fonts

	# casks only work in mac
	brew install --cask kitty
	brew install --cask font-cascadia
	brew install --cask font-jetbrains-mono

	brew install reattach-to-user-namespace
fi

# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# Go setup
mkdir -p $HOME/go/{bin,src,pkg}

# Writting vim will launch nvim
alias vim="nvim"

# Check if the current shell is already zsh
if [ "$SHELL" = "/usr/bin/zsh" ]; then
	echo "DONE!"
else
        if [[ $(uname) == "Linux" ]]; then
		just shell zsh
		# Change the default shell to zsh for future logins
		echo "Log out and back in to use zsh as your default shell."
	fi
fi

echo "Setup complete."
