#!/bin/sh

scriptdir="$(dirname "$0")"
cd "$scriptdir"

if [ -d $HOME/.vim ]; then
    echo "Backing up exising vim config to .vim.old"
    mv $HOME/.vim $HOME/.vim.old
fi
ln -s $PWD/vim $HOME/.vim

if [ -f $HOME/.vimrc ]; then
    echo "Backing up existing vimrc to .vimrc.old"
    mv $HOME/.vimrc $HOME/.vimrc.old
fi
ln -s $PWD/vimrc $HOME/.vimrc

if [ -f $HOME/.inputrc ]; then
    echo "Backing up existing inputrc to .inputrc.old"
    mv $HOME/.inputrc $HOME/.inputrc.old
fi
ln -s $PWD/inputrc $HOME/.inputrc

if [ -f $HOME/.bashrc ]; then
    echo "Backing up existing bashrc to .bashrc.old"
    mv $HOME/.bashrc $HOME/.bashrc.old
fi
ln -s $PWD/bashrc $HOME/.bashrc

if [ -f $HOME/.zshrc ]; then
    echo "Backing up existing zshrc to .zshrc.old"
    mv $HOME/.zshrc $HOME/.zshrc.old
fi
ln -s $PWD/zshrc $HOME/.zshrc

if [ -f $HOME/.aliases ]; then
    echo "Backing up existing aliases to .aliases.old"
    mv $HOME/.aliases $HOME/.aliases.old
fi
ln -s $PWD/aliases $HOME/.aliases

if [ -f $HOME/.functions ]; then
    echo "Backing up existing functions to .functions.old"
    mv $HOME/.functions $HOME/.functions.old
fi
ln -s $PWD/functions $HOME/.functions

if [ -f $HOME/.tmux.conf ]; then
    echo "Backing up existing tmux.conf to .tmux.conf.old"
    mv $HOME/.tmux.conf $HOME/.tmux.conf.old
fi
ln -s $PWD/tmux.conf $HOME/.tmux.conf

if [ -f $HOME/.editorconfig ]; then
    echo "Backing up existing editorconfig to .editorconfig.old"
    mv $HOME/.editorconfig $HOME/.editorconfig.old
fi
ln -s $PWD/editorconfig $HOME/.editorconfig

echo "Creating symlinks for theme"
if [ -f /usr/local/share/zsh/site-functions/prompt_pure_setup ]; then
    rm /usr/local/share/zsh/site-functions/prompt_pure_setup
fi
if [ -f /usr/local/share/zsh/site-functions/async ]; then
    rm /usr/local/share/zsh/site-functions/async
fi
sudo ln -s "$PWD/zsh_custom/themes/pure.zsh-theme" /usr/local/share/zsh/site-functions/prompt_pure_setup
sudo ln -s "$PWD/zsh_custom/async.zsh" /usr/local/share/zsh/site-functions/async

vim +PlugInstall +qall

# echo "To install vim plugins, open vim and run :PlugInstall"

