#!/usr/bin/env bash

UNAME=$( command -v uname)
UNAME=$( "${UNAME}" | tr '[:upper:]' '[:lower:]')

case "${UNAME}" in
  linux*)
	  echo "Installing zsh..."
	  sudo apt install zsh
	  echo "Changing shell to zsh"
	  sudo chsh -s $(which zsh)
	  # Adding homebrew to zprofile
	  echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> /home/charlie/.zprofile
	  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    ;;
  darwin*)
	  printf 'darwin\n'
    ;;
  *)
	  printf 'unknown\n'
    ;;
esac


echo "Installing Oh my zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.config/nvim/coc-settings.json
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config ~/.config/nvim ~/.config/nvim/config

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/vimrc ~/.config/nvim/init.vim
ln -s ~/dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
ln -s ~/dotfiles/config/* ~/.config/nvim/config


echo "Installing brew"
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

case "${UNAME}" in
  linux*)
	  echo "Linux detected. Using Linux config..."
	  echo "Installing JetBrains Mono"
	  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

    ;;
  darwin*)
	echo "Mac detected. Using Mac config..."
	# casks only work in mac
	brew tap homebrew/cask-fonts
	brew install --cask kitty
	brew install --cask font-fira-code
	brew install --cask font-cascadia
	brew install --cask font-jetbrains-mono
	# deno brew formula only works with mac
	brew install deno
	brew install reattach-to-user-namespace
    ;;
  *)
	  printf 'unknown\n'
    ;;
esac

brew install ripgrep
brew install tmux
brew install neovim
brew install python3
brew install ag
brew install fzf
brew install bat
brew install thefuck

# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# install fnm
curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash

# install Plug - Neovim Plugin Manager
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip3 install pynvim

# Writting vim will launch nvim
alias vim="nvim"
