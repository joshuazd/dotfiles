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
export LS_COLORS='di=01;94:ex=01;92:tw=01;94:ow=01;94:ln=01;36:*.mp4=01;35:*.tar=01,31:*.tgz=01;31:*.zip=01;31:*.rar=01;31:*.jar=01;31:*.war=01;31:*.gz=01;31:*.bz2=01;31:*.png=01;35:*.jpg=01;35:*.jpeg=01;35:*.bmp=01;35:*.gif=01;35'
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

source $HOME/dotfiles/zsh_custom/mvncolor.sh
export ZSH_CUSTOM=$HOME/dotfiles/zsh_custom

autoload -Uz promptinit
promptinit
prompt pure

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

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

bindkey -e

export EDITOR=vim
export VISUAL=vim
export KEYTIMEOUT=1
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey '^xe' edit-command-line
bindkey -M emacs ' ' magic-space

change-first-word() {
    zle beginning-of-line -N
    zle kill-word
}
zle -N change-first-word
bindkey -M emacs "\ea" change-first-word

if [[ -d ~/pebble-dev/pebble-sdk-4.5-linux64/bin ]]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -l'
export PATH=$PATH:/snap/bin/

if type fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d'
elif type rg > /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif type ag > /dev/null; then
    export FZF_DEFAULT_COMMAND='ag -l'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if [ -f "${HOME}/.aliases" ]; then
      source "${HOME}/.aliases"
fi

if [ -f "${HOME}/.functions" ]; then
      source "${HOME}/.functions"
fi

source "${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
zle -N history-substring-search-up
zle -N history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=none,fg=magenta,bold'
export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd:cd ..:cd.:zh"
export HISTSIZE=5000
export HISTFILE=~/.zsh_history
export SAVEHIST=5000
setopt append_history
setopt extended_history
setopt share_history
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'l:|=* r:|=*' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:(rm|cp|kill|diff|scp):*' ignore-line yes
zstyle :compinstall filename '/home/vagrant/.zshrc'
autoload -Uz compinit
compinit
