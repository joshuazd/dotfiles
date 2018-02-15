# Installation

`git clone https://github.com/joshuazd/dotfiles.git`
`./dotfiles/install.sh`

This will clone the repository into the dotfiles folder, and run the installation script

The bashrc, zshrc, inputrc, tmux.conf, aliases, functions, editorconfig and vim config will be backed up before installing each file

minvimrc and microvimrc are smaller vim configs that can be used if you don't want plugins, or need to open huge files.
They are aliased to mvi and cvi, respectively

[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) will be installed only if a zsh executable could be found
