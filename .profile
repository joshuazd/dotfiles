
PATH=$HOME/.bin:$HOME/bin:$HOME/.local/bin:$PATH:/snap/bin
LANG=en_US.UTF-8
export PATH LANG

EDITOR=vim\ --noplugin\ -Nu\ ~/dotfiles/nanovimrc
VISUAL=$EDITOR
export EDITOR VISUAL

HISTIGNORE="&:ls:l:[bf]g:exit:reset:clear:cd:cd ..:cd.:zh"
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
HISTSIZE=5000
HISTFILE=~/.history
SAVEHIST=5000
export HISTIGNORE HISTCONTROL HISTSIZE HISTFILE SAVEHIST

JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"
export JAVA_HOME

WORDCHARS='*?_-[]~=&;!#$%^(){}<>'
ZSH_CUSTOM=$HOME/dotfiles/zsh_custom
TMUX_CUSTOM=$HOME/dotfiles/tmux
SHELL=/usr/bin/zsh
export WORDCHARS ZSH_CUSTOM TMUX_CUSTOM SHELL

_gen_fzf_default_opts() {

    case "$1" in
        nier)
            local color00='#45403a'
            local color01='#bf4243'
            local color02='#525643'
            local color03='#5b5143'
            local color04='#4c5361'
            local color05='#614c61'
            local color06='#465953'
            local color07='#999483'
            local color08='#777467'
            local color09='#d75f5f'
            local color0A='#81895d'
            local color0B='#957f5f'
            local color0C='#7382a0'
            local color0D='#9c739c'
            local color0E='#5f8c7d'
            local color0F='#ffffff'
            FZF_DEFAULT_OPTS="
              --color=bg+:$color07,bg:#b4af9a,spinner:$color0C,hl:$color01
              --color=fg:$color08,header:$color0D,info:$color0A,pointer:$color04
              --color=marker:$color04,fg+:$color00,prompt:$color04,hl+:$color01
              --preview='cat {} 2>/dev/null'
            "
            ;;
        *)
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
            FZF_DEFAULT_OPTS="
              --color=bg+:$color08,bg:$color00,spinner:$color0C,hl:$color05
              --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
              --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color05
              --preview='fzf_preview {} 2>/dev/null'
            "
            ;;
    esac

    FZF_CTRL_R_OPTS="--preview=''"
    export FZF_DEFAULT_OPTS FZF_CTRL_R_OPTS
}

_gen_fzf_default_opts material

