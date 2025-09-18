# Functions
zellij_tab_name_update() {
  if [[ -n $ZELLIJ ]]; then
    tab_name=''
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        tab_name+=$(basename "$(git rev-parse --show-toplevel)")/
        tab_name+=$(git rev-parse --show-prefix)
        tab_name=${tab_name%/}
    else
        tab_name=$PWD
            if [[ $tab_name == $HOME ]]; then
            tab_name="~"
             else
            tab_name=${tab_name##*/}
             fi
    fi
    zellij action rename-tab $tab_name >/dev/null 2>&1
  fi
}

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME=""

# User configuration

export EDITOR='nvim'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit -v'
alias gd='git diff'
alias gf='git fetch'
alias glgg='git log --graph'
alias grmc='git rm --cached'
alias gst='git status'

# History configuration
HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Paths
if [[ $OSTYPE = (linux)* ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  open() {
    xdg-open "${@:-.}" &>/dev/null
  }
else
  export ANDROID_HOME="$HOME/Library/Android/sdk"
fi
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Flutter
export PATH="$PATH:`pwd`/flutter/bin"
export PATH=~/.local/bin:$PATH
# Cargo
export PATH="$HOME/.cargo/bin:$PATH"
#Java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# GitHub Credentials
GITHUB_USERNAME=charliesbot

if [[ $OSTYPE = (linux)* ]]; then
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

eval "$(starship init zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if [[ -f "$HOME/.hgrc" ]]; then
  source "$HOME/.zshrc-google-plugin"
fi

# Enable FZF if present
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)

export FZF_DEFAULT_COMMAND='rg --files --fixed-strings --hidden --follow --glob "!.git/*"'

autoload -U add-zsh-hook
add-zsh-hook chpwd zellij_tab_name_update
add-zsh-hook precmd zellij_tab_name_update

