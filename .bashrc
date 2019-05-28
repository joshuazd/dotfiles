
. "$HOME/.shrc"

shopt -s nocaseglob
shopt -s histappend
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

# Aliases
[ -f "${HOME}/.aliases" ] && source "${HOME}/.aliases"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
