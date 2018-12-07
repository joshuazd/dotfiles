#!/bin/sh

scriptdir="$(dirname "$0")"
cd "$scriptdir"

case $(uname -s) in
    Linux*) ./tools.sh ;;
    *) ;;
esac

read -p 'Backup existing files (Y/n)' backup
if [ -z $backup ]; then
    backup='y'
fi

install() {
    if [ -f "$HOME/.$1" ] || [ -d "$HOME/.$1" ]; then
        if [ "$backup" = 'y' ] || [ "$backup" = 'Y' ]; then
            echo "Backing up existing $1 to .$1.old"
            mv "$HOME/.$1" "$HOME/.$1.old"
        else
            rm "$HOME/.$1"
        fi
    fi
    echo "Installing $1"

    case $(uname -s) in
        Linux*|Darwin*) ln -s "$PWD/$1" "$HOME/.$1" ;;
        CYGWIN*)
            currentdir=$(cygpath -w "$scriptdir")
            if [ -d "$PWD/$1" ]; then
                cygstart --action=runas cmd /C "cd %HOME% && mklink /D .$1 $currentdir\\$1"
            elif [ -f "$PWD/$1" ]; then
                cygstart --action=runas cmd /C "cd %HOME% && mklink .$1 $currentdir\\$1"
            fi ;;
        *) ;;
    esac
}

install vim
install vimrc
install inputrc
install bashrc
install zshrc
install aliases
install functions
install tmux.conf
install editorconfig
install bin

echo "Creating symlinks for theme"
if [ -f /usr/local/share/zsh/site-functions/prompt_nier_setup ]; then
    rm /usr/local/share/zsh/site-functions/prompt_nier_setup
fi
if [ -f /usr/local/share/zsh/site-functions/prompt_pure_setup ]; then
    rm /usr/local/share/zsh/site-functions/prompt_pure_setup
fi
if [ -f /usr/local/share/zsh/site-functions/async ]; then
    rm /usr/local/share/zsh/site-functions/async
fi

case $(uname -s) in
    Linux*|Darwin*) sudo ln -s "$PWD/zsh_custom/themes/pure.zsh-theme" /usr/local/share/zsh/site-functions/prompt_pure_setup
                    sudo ln -s "$PWD/zsh_custom/themes/nier.zsh-theme" /usr/local/share/zsh/site-functions/prompt_nier_setup
                    sudo ln -s "$PWD/zsh_custom/async.zsh" /usr/local/share/zsh/site-functions/async ;;
    CYGWIN*) ln -s "$PWD/zsh_custom/themes/pure.zsh-theme" /usr/local/share/zsh/site-functions/prompt_pure_setup
             ln -s "$PWD/zsh_custom/themes/nier.zsh-theme" /usr/local/share/zsh/site-functions/prompt_nier_setup
             ln -s "$PWD/zsh_custom/async.zsh" /usr/local/share/zsh/site-functions/async ;;
    *) ;;
esac

vim +PlugInstall +helptags\ ALL +qall
