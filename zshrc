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
alias gp='git push'
# Branch Management
alias gsw='git switch'
alias gsc='git switch -c'  # Think "Switch & Create"
alias gsm='git switch main' # Quick jump to main/master
# File Recovery (The other half of checkout)
alias grs='git restore'
alias grss='git restore --staged' # To unstage files

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
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
#Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#Java
export JAVA_HOME=$(brew --prefix openjdk@17)
export PATH="$JAVA_HOME/bin:$PATH"

# Bin
export PATH="$HOME/.local/bin:$PATH"

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

# Added by Antigravity
export PATH="/Users/charliesbot/.antigravity/antigravity/bin:$PATH"
