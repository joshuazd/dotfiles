# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

case "$TERM" in
    xterm*) TERM=xterm-256color
esac

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
export LS_COLORS='di=01;94:ex=01;92:tw=01;94:ow=01;94:ln=01;36'
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
export EDITOR='vim'

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    plugins=(git tmux ansible z history-substring-search zsh-autosuggestions zsh-syntax-highlighting)
else
    plugins=(git tmux z history-substring-search zsh-autosuggestions zsh-syntax-highlighting)
    # ZSH_TMUX_AUTOSTART="true"
fi

source $ZSH/oh-my-zsh.sh

# User configuration
#source $ZSH_CUSTOM/mvncolor.sh
alias mvn-color='source $ZSH_CUSTOM/mvncolor.sh'

# export MANPATH="/usr/local/man:$MANPATH"
autoload -U promptinit; promptinit
prompt pure
source $ZSH_CUSTOM/themes/pure.zsh-theme
# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins "^I" expand-or-complete-prefix
bindkey -M viins "^L" clear-screen
bindkey -M viins "^P" up-line-or-history
bindkey -M viins "^N" down-line-or-history
bindkey -M viins "^R" history-incremental-search-backward
bindkey -M viins "^W" backward-kill-word
bindkey -M viins "^A" beginning-of-line
bindkey -M viins "^E" end-of-line
bindkey -M viins ' ' magic-space
bindkey '^x^e' edit-command-line

export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd:cd ..:cd.:zh"
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY


if [[ $(uname -s) != CYGWIN* ]]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi
