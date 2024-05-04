#!/usr/bin/env bash
if [[ `uname` == "Darwin"   ]]; then
  echo "Mac detected. Using Mac config..."
fi

if [[ `uname` == "Linux" ]]; then
  echo "Linux detected. Using Linux config..."
  echo "Updating system packages..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install zsh curl wget build-essential -y
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $HOME/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Installing Kitty Snazzy Theme"
curl -o ~/.config/kitty/snazzy.conf https://raw.githubusercontent.com/connorholyday/kitty-snazzy/master/snazzy.conf

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null
rm -rf ~/.ideavimrc
rm -rf ~/.config/nvim/lua/charliesbot

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config/ ~/.config/nvim/ ~/.config/nvim/lua/ ~/.config/nvim/lua/$USER/

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/nvim/. ~/.config/nvim
#ln -s ~/dotfiles/nvim/lua/charliesbot/. ~/.config/nvim/lua/charliesbot
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
fi

if [[ `uname` == "Darwin"   ]]; then
  echo "Using specific config for Mac"
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

# Change the default shell to zsh
echo "Changing the default shell to zsh for future logins..."
sudo chsh -s $(which zsh) $USER

# Check if the current shell is already zsh
if [ "$SHELL" = "/usr/bin/zsh" ]; then
  echo "DONE!"
else
  # Change the default shell to zsh for future logins
  echo "Setup complete."
  echo "Log out and back in to use zsh as your default shell."
  sudo chsh -s $(which zsh) $USER
fi
