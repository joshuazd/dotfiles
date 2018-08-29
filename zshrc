case "$TERM" in
    xterm*|*rxvt*) TERM=xterm-256color
esac

export LS_COLORS='di=00;94:ex=00;92:tw=00;94:ow=00;94:ln=00;36:*.mp4=00;35:*.tar=00,31:*.tgz=00;31:*.zip=00;31:*.rar=00;31:*.jar=00;31:*.car=00;31:*.war=00;31:*.gz=00;31:*.bz2=00;31:*.png=00;35:*.jpg=00;35:*.jpeg=00;35:*.bmp=00;35:*.gif=00;35:*.vim=00;33:*vimrc=00;33:*.py=00;95:*.xml=00;91:*.md=00;97'
export WORDCHARS='*?_-[]~=&;!#$%^(){}<>'
export LANG=en_US.UTF-8
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
export ZSH_CUSTOM=$HOME/dotfiles/zsh_custom
export TMUX_CUSTOM=$HOME/dotfiles/tmux

source $ZSH_CUSTOM/mvncolor.sh

# setup prompt
autoload -Uz promptinit
promptinit
# prompt pure
prompt nier


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
setopt listpacked

# Editing settings
stty -ixon
bindkey -e
export EDITOR=vim\ -u\ ~/dotfiles/nanovimrc\ -N
export VISUAL=vim\ -u\ ~/dotfiles/nanovimrc\ -N
export KEYTIMEOUT=1
autoload zmv
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

vim-files() {
    zle kill-whole-line
    zle -U "vim -c Files"
}
zle -N vim-files
bindkey '\ev' vim-files

# Add pebble binary to path
if [[ -d ~/pebble-dev/pebble-sdk-4.5-linux64/bin ]]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi

# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -l'
export PATH=$PATH:/snap/bin/

PATH="$HOME/bin:$HOME/.local/bin:$PATH"

if type fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d'
elif type rg > /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
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
compdef sshrc=ssh
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

_gen_fzf_default_opts() {

local color00='#262626'
local color01='#ff5f5f'
local color02='#87d787'
local color03='#ffd787'
local color04='#6182b8'
local color05='#c792ea'
local color06='#89ddff'
local color07='#bbbbbb'
local color08='#3a3a3a'
local color09='#d75f5f'
local color0A='#87af87'
local color0B='#ffaf5f'
local color0C='#82aaff'
local color0D='#945eb8'
local color0E='#39adb5'
local color0F='#ffffff'

export FZF_DEFAULT_OPTS="
  --color=bg+:$color08,bg:$color00,spinner:$color0C,hl:$color05
  --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
  --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color05
"

}

_gen_fzf_default_opts
