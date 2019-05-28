
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
export WORDCHARS ZSH_VERSION TMUX_CUSTOM SHELL

LS_COLORS='di=00;94:ex=00;92:tw=00;94:ow=00;94:ln=00;36:*.mp4=00;35:*.tar=00;31:*.deb=00;31:*.tgz=00;31:*.zip=00;31:*.rar=00;31:*.jar=00;31:*.car=00;31:*.war=00;31:*.gz=00;31:*.bz2=00;31:*.png=00;35:*.jpg=00;35:*.jpeg=00;35:*.bmp=00;35:*.gif=00;35:*.vim=00;33:*vimrc=00;33:*.py=00;95:*.xml=00;91:*.md=00;97'
export LS_COLORS
