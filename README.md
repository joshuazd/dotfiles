# Installation

`git clone https://github.com/joshuazd/dotfiles.git`

`./dotfiles/install.sh`

This will clone the repository into the dotfiles folder, and run the installation script

The bashrc, zshrc, inputrc, tmux.conf, aliases, functions, editorconfig and vim config will be backed up before installing each file

minvimrc and microvimrc are smaller vim configs that can be used if you don't want plugins, or need to open huge files.
They are aliased to mvi and cvi, respectively

## Misc Features

- The 256-colors.sh script will print out all 256 term colors, both as background and as foreground colors.

  Run it using `bash 256-colors.sh`


- The colortrans.py script will convert between hex codes and term colors.  
  It can also match hex codes to their nearest term color equivalent
