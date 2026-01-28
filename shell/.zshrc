
. "$HOME/.shrc"

_git_prompt_info() {
  ref=${$(command git symbolic-ref HEAD 2> /dev/null)#refs/heads/} || \
      ref=${$(command git rev-parse HEAD 2>/dev/null)[1][1,7]} || \
      return
  # echo -n '%F{242} ['
  # echo -n '%F{7} ['
  echo -n '%F{8} ['
  echo -n $ref
  echo -n ']%f'
}

_ruby_prompt() {

    # [ -x "$(command -v rbenv)" ] && ruby_version=$(rbenv version-name)

    # [[ -z $ruby_version || "${ruby_version}" == "system" ]] && return
    
    [ -x "$(command -v ruby)" ] && ruby_version=$(ruby --version | awk '{print $2}')

    [ -x "$(command -v ruby)" ] && ruby_bin=$(which ruby)

    [[ -z $ruby_version || "${ruby_bin}" == "/usr/bin/ruby" ]] && return

    [[ "${ruby_version}" =~ ^[0-9].+$ ]] && ruby_version="v${ruby_version}"

    echo -n "%F{red}💎 ${ruby_version}%f "
}

_python_prompt() {
    local py_version

    if [[ -n "$VIRTUAL_ENV" ]]; then
        py_version=${(@)$(python -V 2>&1)[2]}
    fi

    [[ -z $py_version ]] && return

    echo -n "%F{yellow}🐍 ${py_version}%f "
}

_venv_prompt() {
    [ -n "$VIRTUAL_ENV" ] || return

    VENV_NAME="${(A)=VENV_NAME=virtualenv venv .venv}"

    local venv

    if [[ "${VENV_NAME[(i)$VIRTUAL_ENV:t]}" -le "${#VENV_NAME}" ]]; then
        venv="$VIRTUAL_ENV:h:t"
    else
        venv="$VIRTUAL_ENV:t"
    fi

    echo -n "%F{blue}${venv}%f "
}


_node_prompt() {
    local node_version

    node_version=$(fnm current 2>/dev/null)

    default_version="v20.15.1"

    [[ $node_version == "system" || $node_version == $default_version || $node_version == "node" || $node_version == "none" ]] && return

    echo -n "%F{green}⬢ ${node_version}%f "
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
# PROMPT=" %F{234}%~%f\$(_git_prompt_info) %F{%(?.234.red)}%(!.#.>)%f "
PROMPT=" %F{111}%~%f\$(_git_prompt_info) \$(_ruby_prompt)\$(_python_prompt)\$(_venv_prompt)\$(_node_prompt)
%F{%(?.222.red)}%(!.#.$)%f "
setopt promptsubst

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
    fbr; zle reset-prompt;
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

zle -N fco_preview
bindkey '^o' fco_preview

_fzf_complete_sshrc() {
  _fzf_complete '+m' "$@" < <(
    command cat <(cat ~/.ssh/config /etc/ssh/ssh_config 2> /dev/null | command grep -i '^host ' | command grep -v '[*?]' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}') \
        <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

[ -x "$(command -v rbenv)" ] && eval "$(rbenv init - zsh)"

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
# zstyle :compinstall filename '/home/vagrant/.zshrc'
autoload -Uz compinit
compinit
# plugins
fpath=($fpath ${ZSH_CUSTOM}/plugins/git)
source "${ZSH_CUSTOM}/plugins/git/git.plugin.zsh"
source "${ZSH_CUSTOM}/my_scripts.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_CUSTOM}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=none,fg=magenta,bold'
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
setopt append_history
setopt extended_history
setopt share_history
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

compdef _jzd jzd

_jzd() {
  local cmd=$(basename $words[1])
  if [[ $CURRENT = 2 ]]; then
    local tmp
    tmp=($(grep '^    [a-z0-9-]*[|)]' "$HOME/.bin/$cmd" 2>/dev/null | sed -e 's/).*//' | tr '|' ' '))
    _describe -t commands "${words[1]} command" tmp --
  else
    shift words
    (( CURRENT-- ))
    curcontext="${curcontext%:*:*}:$cmd-${words[1]}:"

    local selector=$(egrep "^    ([a-z0-9-]*[|])*${words[1]}([|][a-z0-9-]*)*[)] *# *[_a-z0-9-]*$" "$HOME/.bin/$cmd" | sed -e 's/.*# *//')
    _call_function ret _$selector && return $ret

    if [[ -n "$selector" ]]; then
      words[1]=$selector
    elif [[ -f "$HOME/.bin/$cmd-${words[1]}" ]]; then
      words[1]=$cmd-${words[1]}
      _jzd
    fi
    _normal
  fi
}

_256colors() {
    nums=({1..256})
    _describe -t commands "${words[1]} command" nums --
    return 0
}
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5c6370'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6b7895'
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=magenta'
alias hp_development='HP_AWS_ACCESS_KEY_ID=`security find-generic-password -w -s hushpuppy_development_ro_api_key_id -a jzinkduda` HP_AWS_SECRET_ACCESS_KEY=`security find-generic-password -w -s hushpuppy_development_ro_api_key_secret -a jzinkduda` CONFIG_NAME=Development'
alias hp_test='HP_AWS_ACCESS_KEY_ID=`security find-generic-password -w -s hushpuppy_test_rw_api_key_id -a jzinkduda` HP_AWS_SECRET_ACCESS_KEY=`security find-generic-password -w -s hushpuppy_test_rw_api_key_secret -a jzinkduda` CONFIG_NAME=Test'
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# FNM (node version management and autoload)
[ -x "$(command -v fnm)" ] && eval "$(fnm env)"

FNM_USING_LOCAL_VERSION=0
FNM_VERSION_FILE_STRATEGY=recursive

autoload -U add-zsh-hook
_fnm_autoload_hook () {
  if [[ -f .nvmrc && -r .nvmrc || -f .node-version && -r .node-version ]]; then
    FNM_USING_LOCAL_VERSION=1
    fnm use --install-if-missing >/dev/null
  elif [ $FNM_USING_LOCAL_VERSION -eq 1 ]; then
    FNM_USING_LOCAL_VERSION=0
    fnm use default --install-if-missing >/dev/null
  fi
}

add-zsh-hook chpwd _fnm_autoload_hook \
    && _fnm_autoload_hook

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
source /Users/joshua.zink-duda/.hunt-cli/autocomplete_zsh
