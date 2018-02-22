# Installation

`git clone https://github.com/joshuazd/dotfiles.git`

`./dotfiles/install.sh`

This will clone the repository into the dotfiles folder, and run the installation script

The bashrc, zshrc, inputrc, tmux.conf, aliases, functions, editorconfig and vim config will be backed up before installing each file

minvimrc is a drop-in replacement that can be used as a single file vim config, e.g. on remote servers. 
It has no plugins, but contains useful functions, maps, and settings.  It is aliased to mvi

microvimrc is a smaller config that disables syntax highlighting. It is aliased to cvi, which also disables plugins. 
It is suitable for editing large files

## Misc Features

- The 256-colors.sh script will print out all 256 term colors, both as background and as foreground colors.

  Run it using `bash 256-colors.sh`


- The colortrans.py script will convert between hex codes and term colors.  
  It can also match hex codes to their nearest term color equivalent
