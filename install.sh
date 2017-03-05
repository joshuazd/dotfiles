# initialize submodules
git submodule init
git submodule update
git submodule foreach git pull

if [ ! -d $HOME/.vim ]; then
    echo "Creating vim config"
    ln -s $PWD/.vim $HOME/.vim
else
    echo "Vim config already exists"
fi

ln -s $PWD/.vim/vimrc $HOME/.vimrc
ln -s $PWD/.bash_aliases $HOME/.bash_aliases
ln -s $PWD/.bashrc $HOME/.bashrc

