# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

[ -f "${HOME}/.shrc" ] && source "${HOME}/.shrc"

# Don't wait for job termination notification
# set -o notify

# Use case-insensitive filename globbing
shopt -s nocaseglob

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
 [[ -f /etc/bash_completion ]] && . /etc/bash_completion

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

_build_prompt() {
    ret=$([ $? -eq 0 ] && echo '33' || echo '31')
    prompt="\e[94m$(dirs +0)\e[m\e["

    case "$TERM" in
        *-256color) prompt+='38;5;242' ;;
        *)          prompt+='91'       ;;
    esac
    prompt+="m$(_git_prompt_info)\e["$ret"m $\e[m"

    echo -ne " "$prompt" "
}

PS1="\$(_build_prompt)"
# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls:l'

# Aliases
[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
