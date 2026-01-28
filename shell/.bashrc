####################################
# BASH CONFIGURATION
####################################
# Sources: .bash_profile → .profile → .shrc → .bashrc
# This file contains bash-specific settings

. "$HOME/.shrc" 2>/dev/null

shopt -s nocaseglob
shopt -s histappend
shopt -s cdspell

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
 [[ -f /etc/bash_completion ]] && . /etc/bash_completion

set -o vi

# Only run bind commands in proper interactive shells with job control
if [[ $- == *i* ]] && [[ -t 0 ]]; then
  bind -m vi-insert '"\C-p": previous-history' 2>/dev/null
  bind -m vi-insert '"\C-n": next-history' 2>/dev/null
fi

# Load shared functions (includes parse_git_branch)
[ -f "${HOME}/.functions" ] && source "${HOME}/.functions"

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

[ -x "$(command -v rbenv)" ] && eval "$(rbenv init - bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
