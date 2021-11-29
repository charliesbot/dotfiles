# Initialize completion
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# This fixes prompt error from Pure
fpath+=$HOME/.zsh/pure

# fnm
# export PATH=/Users/charlie/.fnm:$PATH
eval "`fnm env`"

# fuck!
eval $(thefuck --alias)

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME=""


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='nvim'

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# alias
# alias python=/usr/local/bin/python3
alias pip=pip3

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Paths
export ANDROID_HOME=/Users/charlie/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Flutter
export PATH="$PATH:`pwd`/flutter/bin"
export PATH=~/.local/bin:$PATH
# Cargo
export PATH="$HOME/.cargo/bin:$PATH"
# Deno
export PATH="${HOME}/.deno/bin:$PATH"
# CPP
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

# Lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# GitHub Credentials
GITHUB_USERNAME=charliesbot

# pipenv
export PIP_CONFIG_FILE=~/.config/pip/pip.conf

# FZF Sugar

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)

export FZF_DEFAULT_COMMAND='rg --files --fixed-strings --hidden --follow --glob "!.git/*"'

export PATH="/usr/local/sbin:$PATH"

# Pure theme
autoload -U promptinit; promptinit
prompt pure

# Pyenv
if [[ $OSTYPE = (linux)* ]]; then
  export PATH="/home/charlie/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

### End of Zinit's installer chunk
