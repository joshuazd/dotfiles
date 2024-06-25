
. "$HOME/.shrc" 2>/dev/null

shopt -s nocaseglob
shopt -s histappend
shopt -s cdspell

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
 [[ -f /etc/bash_completion ]] && . /etc/bash_completion

set -o vi
bind -m vi-insert '"\C-p": previous-history'
bind -m vi-insert '"\C-n": next-history'

_git_prompt_info() {
    sym=$(command git symbolic-ref HEAD 2> /dev/null)
    rev=$(command git rev-parse HEAD 2> /dev/null)
    ref=${sym#refs/heads/} || \
      ref=${rev[1][1,7]} || \
      return 0
      if [ -n "$ref" ]; then
          echo -n " ["
          echo -n $ref
          echo -n "]"
      fi
}

# _build_prompt() {
#     # ret=$([ $? -eq 0 ] && echo '93' || echo '31')
#     # prompt="\e[94m$(dirs +0)\e[m\e["
#     prompt="$(dirs +0)"
#     # case "$TERM" in
#     #     *-256color) prompt+='38;5;242' ;;
#     #     *)          prompt+='91'       ;;
#     # esac
#     # prompt+="m$(_git_prompt_info)\e["$ret"m $\e[m"
#     prompt+=" $"
#     echo -ne " "$prompt" "
# }

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		echo "[${BRANCH}] "
	else
		echo ""
	fi
}

function _prompt_symbol() {
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        PROMPT_SYMBOL="\[\e[31m"
        # echo -ne "\e[31m"
    else
        PROMPT_SYMBOL="\[\e[93m"
        # echo -ne "\e[93m"
    fi
}

function _build_prompt() {
    _prompt_symbol $?
    PS1=" \[\e[94m\]\w\[\e[m\] \[\e[38;5;242m\]\`parse_git_branch\`\[\e[m\]\[${PROMPT_SYMBOL}\]\\$\[\e[m\] "
}

PROMPT_COMMAND=_build_prompt
# PS1="\$(_build_prompt)"

# Aliases
[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"

[ -x "$(command -v rbenv)" ] && eval "$(rbenv init - zsh)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
