# Initialize completion

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME=""

# User configuration

export EDITOR='nvim'

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# alias python=/usr/local/bin/python3
alias pip=pip3

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Paths
if [[ $OSTYPE = (linux)* ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
else
  export ANDROID_HOME="$HOME/Library/Android/sdk"
fi
export ANDROID_SDK_ROOT=${ANDROID_HOME}
# export PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}
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

# NVM
source $(brew --prefix nvm)/nvm.sh

# export JAVA_HOME=`/usr/libexec/java_home -v 21.0.3`

if [[ $OSTYPE = (linux)* ]]; then
  # Put here commands related to Linux envs
fi

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

