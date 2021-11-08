ZSH_THEME_GIT_PROMPT_UNTRACKED='?'
ZSH_THEME_GIT_PROMPT_ADDED='+'
ZSH_THEME_GIT_PROMPT_MODIFIED='*'
ZSH_THEME_GIT_PROMPT_RENAMED='~'
ZSH_THEME_GIT_PROMPT_DELETED='-'
ZSH_THEME_GIT_PROMPT_UNMERGED='%'
ZSH_THEME_GIT_PROMPT_AHEAD='▲'
ZSH_THEME_GIT_PROMPT_BEHIND='▼'
ZSH_THEME_GIT_PROMPT_DIRTY='✗'

function prompt_char {
    if [ $UID -eq 0 ]; then
        echo "#"
    # elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    #     # echo '›'
    #     # echo '〉'
    #     echo '❯ '
    else
        # echo '»'
        # echo '⟫ '
        echo '❯ '
    fi
}

function prompt_start {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # echo 'γ'
        echo 'Δ'
    else
        echo 'λ'
    fi
}

function virtualenv_info {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv="${VIRTUAL_ENV##*/}"
    else
        venv=''
    fi
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        [[ -n "$venv" ]] && echo " $FG[003]$venv%{$reset_color%}"
    else
        [[ -n "$venv" ]] && echo " $FG[003]$venv%{$reset_color%}"
    fi
}

function user {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # echo -n "$BG[008] %{$fg[green]%}%n $BG[012]$FG[008]$SEP"
        echo -n ""
    else
        echo -n ""
    fi
}


function custom_git_status {
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    if [[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then

        # git update-index --really-refresh -q &>/dev/null

        # local indicators=''
        # if ! $(git diff --quiet --ignore-submodules --cached); then
        #     # uncommited changes
        #     indicators+='+'
        # fi
        # if ! $(git diff-files --quiet --ignore-submodules --); then
        #     # unstaged changes

        #     # indicators+=$'\u26a1'
        #     indicators+='*'
        # fi
        # if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        #     # untracked files
        #     indicators+='?'
        # fi

        # local count
        # count="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"
        # # exit if the command failed
        # # (( !$? )) || return
        # count=(${(ps:\t:)count})
        # local arrows left=${count[1]} right=${count[2]}

        # (( ${right:-0} > 1 )) && arrows+="${right:-0}"
        # (( ${right:-0} > 0 )) && arrows+="▼"
        # (( ${left:-0} > 1 )) && arrows+="${left:-0}"
        # (( ${left:-0} > 0 )) && arrows+="▲"

        # indicators+="$arrows"

        # if [[ $indicators != '' ]]; then
        #    local ind=$indicators
        #    indicators=' '
        #    indicators+=$ind
        # fi

        #repo=$(current_repository)
        #local temp=$(echo $repo | grep -oPm1 "(?<=/)[a-zA-Z\.0-9_\-]+(?=\.git \(push\))")

        #[ -n "${indicators}" ] && indicators=" [${indicators}]";
        # BRANCH=$'\ue0a0'
        #BRANCH=':'
        #CUSTOM_THEME_GIT_PROMPT_PREFIX=""
        #CUSTOM_THEME_GIT_PROMPT_SUFFIX=""
        # echo -n "%{$fg[red]%}$RIGHT_SEP%{$bg[red]%}%{$fg[black]%}${CUSTOM_THEME_GIT_PROMPT_PREFIX}$temp $BRANCH $(git_current_branch) $indicators"
        STATUS=$(parse_git_dirty)$(git_prompt_ahead)$(git_prompt_behind)
        if [[ $STATUS != '' ]]; then
            STATUS=' '$STATUS
        fi
        echo -n "$FG[011]$(git_current_branch)$STATUS"
    fi

}

# SEP=$'\ue0b0'
# RIGHT_SEP=$'\ue0b2'

# PROMPT='$(virtualenv_info)$(user)$BG[012]$FG[008] %2~ $BG[013]$FG[012]$SEP%{$fg[black]%}$(prompt_char)%{$reset_color%}$FG[013]$SEP%{$reset_color%} '
PROMPT='$FG[009]$(prompt_start)%{$reset_color%}$(virtualenv_info)$(user)$FG[012] %1~ $FG[010]$(prompt_char)%{$reset_color%}'

RPS1='$(vi_mode_prompt_info)%{$reset_color%}$(custom_git_status)%{$reset_color%}'

MODE_INDICATOR="%{$fg_bold[green]%}<%{$reset_color%}%{$fg[green]%}<<%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
