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
  echo "Installing PyEnv"
  curl https://pyenv.run | bash
fi

echo "Installing Oh my zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing zInit"
sh -c "$(curl -fsSL https://git.io/zinit-install)"

echo "Installing Kitty Snazzy Theme"
curl -o ~/.config/kitty/snazzy.conf https://raw.githubusercontent.com/connorholyday/kitty-snazzy/master/snazzy.conf

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config ~/.config/nvim ~/.config/nvim/lua

echo "Installing Python 3"
# install python 3
pyenv install 3.9.5 #latest
pyenv global 3.9.5

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/init.lua ~/.config/nvim/init.lua
ln -s ~/dotfiles/lua/* ~/.config/nvim/lua
ln -s ~/dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
ln -s ~/dotfiles/wezterm.lua ~/.wezterm.lua

# Italics and true color profile for tmux
tic -x tmux.terminfo

echo "Installing brew"
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install ripgrep
brew install tmux
brew install neovim
brew install ag
brew install fzf
brew install bat
brew install thefuck
brew install go
brew install llvm
brew install gcc
brew install gdb
brew install bazel
brew install cmake
brew install luarocks

# FORMATTERS
brew install shfmt
brew install clang-format

if [[ `uname` == "Linux"   ]]; then
  echo "Linux detected. Using Linux config..."
  echo "Installing JetBrains Mono"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
  echo "Installing pyenv"
fi

if [[ `uname` == "Darwin"   ]]; then
  echo "Mac detected. Using Mac config..."
  brew install pyenv

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

# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# install fnm
curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash

# install Paq - Neovim Plugin Manager
git clone https://github.com/savq/paq-nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim

pip3 install pynvim

# pure prompt manual config
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# lua formatter
luarocks install --server=https://luarocks.org/dev luaformatter

# Go setup
mkdir -p $HOME/go/{bin,src,pkg}

# Writting vim will launch nvim
alias vim="nvim"
