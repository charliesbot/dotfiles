brew install zsh tmux neovim/neovim/neovim python3 ag reattach-to-user-namespace
brew tap caskroom/cask
brew cask install iterm2

# install Plug - Neovim Plugin Manager
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip3 install neovim

# uff, fira code is love
brew tap caskroom/fonts
brew cask install font-fira-code

# remove files if they already exist
rm -rf ~/.vim ~/.vimrc ~/.zshrc ~/.tmux ~/.tmux.conf ~/.config/nvim 2> /dev/null

# Neovim expects some folders already exist
mkdir -p ~/.config ~/.config/nvim

# Symlinking files
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/vimrc ~/.config/nvim/init.vim

# Writting vim will launch nvim
# alias vim="nvim" to your init.sh

