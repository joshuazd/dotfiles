function prompt_char {
    if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

CUSTOM_THEME_GIT_PROMPT_PREFIX="["
CUSTOM_THEME_GIT_PROMPT_SUFFIX="] "

function custom_git_status {
    command git rev-parse --is-inside-work-tree &>/dev/null || return

    if [[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then

        git update-index --really-refresh -q &>/dev/null

        local indicators=''
        if ! $(git diff --quiet --ignore-submodules --cached); then
            # uncommited changes
            indicators+='+'
        fi
        if ! $(git diff-files --quiet --ignore-submodules --); then
            # unstaged changes
            indicators+='*'
        fi
        if [ -n "$(git ls-files --others --exclude-standard)" ]; then
            # untracked files
            indicators+='?'
        fi

        local count
        count="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"
        # exit if the command failed
        (( !$? )) || return
        count=(${(ps:\t:)count})
        local arrows left=${count[1]} right=${count[2]}

        (( ${right:-0} > 0 )) && arrows+="${right:-0}↓"
        (( ${left:-0} > 0 )) && arrows+="${left:-0}↑"

        indicators+="$arrows"


        #[ -n "${indicators}" ] && indicators=" [${indicators}]";

        echo -n "${CUSTOM_THEME_GIT_PROMPT_PREFIX}$(git_current_branch)$indicators${CUSTOM_THEME_GIT_PROMPT_SUFFIX}"
    fi

}

PROMPT='%{$fg[green]%}%n %{$fg[blue]%}%1~ %{$fg[red]%}$(custom_git_status)% %{$fg[yellow]%}$(prompt_char)%{$reset_color%} '

RPS1='$(vi_mode_prompt_info)'

MODE_INDICATOR="%{$fg_bold[green]%}<%{$reset_color%}%{$fg[green]%}<<%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
