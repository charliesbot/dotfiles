#!/usr/bin/env bash

if [[ `uname` == "Linux"   ]]; then
  echo "Linux detected. Using Linux config..."
  echo "Installing zsh..."
  sudo apt install zsh
  echo "Changing shell to zsh"
  sudo chsh -s $(which zsh)
  # Adding homebrew to zprofile
  echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> /home/charlie/.zprofile
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

echo "Installing Kitty Snazzy Theme"
curl -o ~/.config/kitty/snazzy.conf https://raw.githubusercontent.com/connorholyday/kitty-snazzy/master/snazzy.conf

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.config/nvim/coc-settings.json
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null
rm -rf ~/.ideavimrc

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config/ ~/.config/nvim/ ~/.config/nvim/lua/ ~/.config/nvim/lua/charliesbot/

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/nvim/* ~/.config/nvim/
ln -s ~/dotfiles/nvim/lua/charliesbot/* ~/.config/nvim/lua/charliesbot
ln -s ~/dotfiles/wezterm.lua ~/.wezterm.lua
ln -s ~/dotfiles/ideavimrc ~/.ideavimrc

# Italics and true color profile for tmux
tic -x tmux.terminfo

echo "Installing brew"
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

if [[ `uname` == "Linux"   ]]; then
  echo "Linux detected. Using Linux config..."
  echo "Installing JetBrains Mono"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
  echo "Installing pyenv"
fi

if [[ `uname` == "Darwin"   ]]; then
  echo "Mac detected. Using Mac config..."
  # disable key repeat
  defaults write -g ApplePressAndHoldEnabled -bool false

  brew tap homebrew/cask-fonts

  # casks only work in mac
  brew install --cask kitty
  brew install --cask font-fira-code
  brew install --cask font-cascadia
  brew install --cask font-jetbrains-mono
  brew install --cask font-iosevka
  brew install --cask rectangle

  brew install deno # deno brew formula only works with mac
  brew install reattach-to-user-namespace
fi

echo "Installing Python 3"
# install python 3
#pyenv install-latest
#pyenv global 3.9.5

# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# pure prompt
brew install pure

# Go setup
mkdir -p $HOME/go/{bin,src,pkg}

# Writting vim will launch nvim
alias vim="nvim"
