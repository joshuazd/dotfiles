#!/bin/zsh
# install oh my zsh
echo "Installing oh my zsh"
if [ -f /bin/zsh -o -f /usr/bin/zsh -o -f /bin/zsh.exe -o -f /usr/bin/zsh.exe ]; then
    if [[ ! -d $HOME/.oh-my-zsh/ ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
fi

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

echo "To install vim plugins, open vim and run :PlugInstall"
