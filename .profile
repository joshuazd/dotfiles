
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
