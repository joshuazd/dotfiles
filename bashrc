# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

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

# export PS1=" \[\e[94m\]\W\[\e[m\] \[\e[35m\]\`parse_git_branch\`\[\e[31m\]❯\[\e[m\]\[\e[33m\]❯\[\e[m\]\[\e[92m\]❯\[\e[m\] "
export PS1=" \[\e[94m\]\W\[\e[m\] \[\e[35m\]\`parse_git_branch\`\[\e[33m\]$\[\e[m\] "
# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls:l'

export EDITOR=vim\ -u\ ~/dotfiles/nanovimrc\ -N
export VISUAL=vim\ -u\ ~/dotfiles/nanovimrc\ -N

# Aliases
if [ -f "${HOME}/.aliases" ]; then
  source "${HOME}/.aliases"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='ag -l'
export PATH=$PATH:/snap/bin/

PATH="$HOME/.bin:$HOME/bin:$HOME/.local/bin:$PATH"

if type fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d'
elif type rg > /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
