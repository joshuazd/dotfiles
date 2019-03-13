case "$TERM" in
    xterm*|*rxvt*) TERM=xterm-256color
esac

[ -f "${HOME}/.shrc" ] && source ~/.shrc

export WORDCHARS='*?_-[]~=&;!#$%^(){}<>'
export LANG=en_US.UTF-8
export ZSH_CUSTOM=$HOME/dotfiles/zsh_custom
export TMUX_CUSTOM=$HOME/dotfiles/tmux
export SHELL=/usr/bin/zsh

# setup prompt
# autoload -Uz promptinit
# promptinit
# prompt pure

_git_prompt_info() {
  ref=${$(command git symbolic-ref HEAD 2> /dev/null)#refs/heads/} || \
      ref=${$(command git rev-parse HEAD 2>/dev/null)[1][1,7]} || \
      return
  print -Pn '%F{242} [$ref]%f'
}

export PROMPT=" %F{111}%~%f\$(_git_prompt_info)
%F{%(?.222.red)}%(!.#.$)%f "
setopt promptsubst

# typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[function]='none'
# ZSH_HIGHLIGHT_STYLES[command]='none'
# ZSH_HIGHLIGHT_STYLES[alias]='none'
# ZSH_HIGHLIGHT_STYLES[builtin]='none'

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
zmodload zsh/zle
bindkey -v
export KEYTIMEOUT=1
autoload zmv
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
bindkey '^xe' edit-command-line
bindkey -M emacs ' ' magic-space
bindkey -M viins ' ' magic-space
bindkey '^e' autosuggest-accept

change-first-word() {
    zle beginning-of-line -N
    zle kill-word
}
zle -N change-first-word
bindkey -M emacs "\ea" change-first-word
bindkey "\ea" change-first-word

vim-files() {
    zle kill-whole-line
    zle -U "vim -c Files"
}
zle -N vim-files
bindkey '\ev' vim-files

precmd() { RPROMPT="" }
function zle-line-init zle-keymap-select {
    case $KEYMAP in
        vicmd)      RPS1="%F{blue}-- NORMAL --%f" ;;
        main|viins) RPS1="" ;;
    esac
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

__fgitsel() {
  local cmd="git status --short | awk ' { print \$2 }'"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

git-files() {
  LBUFFER="${LBUFFER}$(__fgitsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   git-files
bindkey '^g' git-files

bindkey '\e.' insert-last-word

fgitbranch() {
    fbr
}
zle -N fgitbranch
bindkey '^b' fgitbranch

# Add pebble binary to path
if [[ -d ~/pebble-dev/pebble-sdk-4.5-linux64/bin ]]; then
    export PATH=$PATH:~/pebble-dev/pebble-sdk-4.5-linux64/bin
fi

# Source alias and function files
[ -f "${HOME}/.aliases" ] && source ~/.aliases
[ -f "${HOME}/.functions" ] && source ~/.functions

_fzf_complete_sshrc() {
  _fzf_complete '+m' "$@" < <(
    command cat <(cat ~/.ssh/config /etc/ssh/ssh_config 2> /dev/null | command grep -i '^host ' | command grep -v '[*?]' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}') \
        <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

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
# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
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
export CDPATH=.:~/projects
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
  --preview='fzf_preview {} 2>/dev/null'
"
export FZF_CTRL_R_OPTS="--preview=''"
}


# _gen_fzf_default_opts() {

# local color00='#45403a'
# local color01='#bf4243'
# local color02='#525643'
# local color03='#5b5143'
# local color04='#4c5361'
# local color05='#614c61'
# local color06='#465953'
# local color07='#999483'
# local color08='#777467'
# local color09='#d75f5f'
# local color0A='#81895d'
# local color0B='#957f5f'
# local color0C='#7382a0'
# local color0D='#9c739c'
# local color0E='#5f8c7d'
# local color0F='#ffffff'

# export FZF_DEFAULT_OPTS="
#   --color=bg+:$color07,bg:#b4af9a,spinner:$color0C,hl:$color01
#   --color=fg:$color08,header:$color0D,info:$color0A,pointer:$color04
#   --color=marker:$color04,fg+:$color00,prompt:$color04,hl+:$color01
# "

# }

_gen_fzf_default_opts
