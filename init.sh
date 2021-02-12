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

echo "Installing Oh my zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Removing existing dotfiles"
# remove files if they already exist
rm -rf ~/.config/nvim/coc-settings.json
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null

echo "Creating symlinks"
# Neovim expects some folders already exist
mkdir -p ~/.config ~/.config/nvim ~/.config/nvim/lua

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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew install ripgrep
brew install tmux
brew install --HEAD neovim # until nvim 0.5 becomes stable
brew install ag
brew install fzf
brew install bat
brew install thefuck

if [[ `uname` == "Linux"   ]]; then
  echo "Linux detected. Using Linux config..."
  echo "Installing JetBrains Mono"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
  echo "Installing pyenv"
  curl https://pyenv.run | bash
fi

if [[ `uname` == "Darwin"   ]]; then
  echo "Mac detected. Using Mac config..."
  brew tap homebrew/cask-fonts
  brew tap wez/wezterm

  # casks only work in mac
  brew install --cask kitty
  brew install --cask font-fira-code
  brew install --cask font-cascadia
  brew install --cask font-jetbrains-mono
  brew install --cask font-iosevka
  brew install --cask spotify
  brew install --cask alfred
  brew install --cask visual-studio-code-insiders
  brew install --cask discord
  brew install --cask telegram-desktop
  brew install --cask grammarly
  brew install --cask google-chrome
  brew install --cask 1password
  brew install --cask rectangle
  brew install --cask dash
  brew install --cask soundsource

  brew install pyenv
  brew install wezterm
  brew install deno # deno brew formula only works with mac
  brew install reattach-to-user-namespace
fi


# FZF shortcuts
$(brew --prefix)/opt/fzf/install

# install python 3
pyenv install 3.9.1 #latest
pyenv global 3.9.1

# install fnm
curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash

# install Paq - Neovim Plugin Manager
git clone https://github.com/savq/paq-nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim

pip3 install pynvim

# pure prompt manual config
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# Writting vim will launch nvim
alias vim="nvim"
