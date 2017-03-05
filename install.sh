# initialize submodules
git submodule init
git submodule update
git submodule foreach git pull

if [ -d $HOME/.vim ]; then
    echo "Backing up exising vim config to .vim.old"
    mv $HOME/.vim $HOME/.vim.old
fi
ln -s $PWD/.vim $HOME/.vim

if [ -f $HOME/.vimrc ]; then
    echo "Backing up existing vimrc to .vimrc.old"
    mv $HOME/.vimrc $HOME/.vimrc.old
fi
ln -s $PWD/.vim/vimrc $HOME/.vimrc

if [ -f $HOME/.bash_aliases ]; then
    echo "Backing up existing bash_aliases to .bash_aliases.old"
    mv $HOME/.bash_aliases $HOME/.bash_aliases.old
fi
ln -s $PWD/.bash_aliases $HOME/.bash_aliases

if [ -f $HOME/.bashrc ]; then
    echo "Backing up existing bashrc to .bashrc.old"
    mv $HOME/.bashrc $HOME/.bashrc.old
fi
ln -s $PWD/.bashrc $HOME/.bashrc

if [ -f $HOME/.zshrc ]; then
    echo "Backing up existing zshrc to .zshrc.old"
    mv $HOME/.zshrc $HOME/.zshrc.old
fi
ln -s $PWD/.zshrc $HOME/.zshrc

if [ -f $HOME/.zsh_aliases ]; then
    echo "Backing up existing zsh_aliases to .zsh_aliases.old"
    mv $HOME/.zsh_aliases $HOME/.zsh_aliases.old
fi
ln -s $PWD/.zsh_aliases $HOME/.zsh_aliases

if [ -f $HOME/.tmux.conf ]; then
    echo "Backing up existing tmux.conf to .tmux.conf.old"
    mv $HOME/.tmux.conf $HOME/.tmux.conf.old
fi
ln -s $PWD/.tmux.conf $HOME/.tmux.conf

