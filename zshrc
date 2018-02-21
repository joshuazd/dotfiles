case "$TERM" in
    xterm*) TERM=xterm-256color
esac

export LS_COLORS='di=01;94:ex=01;92:tw=01;94:ow=01;94:ln=01;36:*.mp4=01;35:*.tar=01,31:*.tgz=01;31:*.zip=01;31:*.rar=01;31:*.jar=01;31:*.war=01;31:*.gz=01;31:*.bz2=01;31:*.png=01;35:*.jpg=01;35:*.jpeg=01;35:*.bmp=01;35:*.gif=01;35'
export LANG=en_US.UTF-8
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
export ZSH_CUSTOM=$HOME/dotfiles/zsh_custom

source $HOME/dotfiles/zsh_custom/mvncolor.sh

# setup prompt
autoload -Uz promptinit
promptinit
prompt pure


# Options
setopt autocd
setopt extendedglob
setopt nomatch
setopt nobeep
setopt completeinword
setopt autopushd
setopt pushdignoredups
setopt noclobber
setopt correct
setopt globcomplete

# Editing settings
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

# Add pebble binary to path
if [[ -d ~/pebble-dev/pebble-sdk-4.5-linux64/bin ]]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi

# fzf setup
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

# Source alias and function files
if [ -f "${HOME}/.aliases" ]; then
      source "${HOME}/.aliases"
fi

if [ -f "${HOME}/.functions" ]; then
      source "${HOME}/.functions"
fi

# completion settings
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{-_}={_-}' 'l:|=* r:|=*' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:(rm|cp|kill|diff|scp):*' ignore-line yes
zstyle :compinstall filename '/home/vagrant/.zshrc'
autoload -Uz compinit
compinit
# plugins
fpath=($fpath ${ZSH_CUSTOM}/plugins/git)
source "${ZSH_CUSTOM}/plugins/git/git.plugin.zsh"
source "${ZSH_CUSTOM}/my_scripts.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
# history settings
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

