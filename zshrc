# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

case "$TERM" in
    xterm*) TERM=xterm-256color
esac

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

HYPHEN_INSENSITIVE="true"
export LS_COLORS='di=01;94:ex=01;92:tw=01;94:ow=01;94:ln=01;36'
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom

plugins=(git tmux ansible z history-substring-search zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration
alias mvn-color='source $ZSH_CUSTOM/mvncolor.sh'

autoload -U promptinit; promptinit
prompt pure
# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

if [ -f "${HOME}/.aliases" ]; then
      source "${HOME}/.aliases"
fi

if [ -f "${HOME}/.functions" ]; then
      source "${HOME}/.functions"
fi

# Options
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NOMATCH
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt NO_CLOBBER
setopt CORRECT
setopt GLOB_COMPLETE

stty -ixon

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=none,fg=magenta,bold'

export EDITOR=vim
export VISUAL=vim
# bindkey -v
export KEYTIMEOUT=1
bindkey '^x^e' edit-command-line

export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd:cd ..:cd.:zh"
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
if [ -d "~/pebble-dev/pebble-sdk-4.5-linux64/bin" ]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi
