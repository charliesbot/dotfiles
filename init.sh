brew tap homebrew/cask-fonts

# main important thing - node
brew install tmux
brew install neovim
brew install python3
brew install ag
brew install reattach-to-user-namespace
brew install node
brew install fzf
brew install bat
brew install thefuck
brew cask install iterm2-beta
brew cask install kitty
brew cask install font-fira-code
brew cask install font-cascadia
brew cask install font-jetbrains-mono

# install Plug - Neovim Plugin Manager
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip3 install neovim

# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null

# Neovim expects some folders already exist
mkdir -p ~/.config ~/.config/nvim ~/.config/nvim/config

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/vimrc ~/.config/nvim/init.vim

# Symlink vim config
ln -s ~/dotfiles/config/* ~/.config/nvim/config

# Writting vim will launch nvim
alias vim="nvim"
