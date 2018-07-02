# Installation

`git clone https://github.com/joshuazd/dotfiles.git`

`./dotfiles/install.sh`

## Install Tools

`./dotfiles/tools.sh`

This will install fd (find replacement), and ag and rg (grep replacements)

## Build vim from source

My personal vim config is [here](https://github.com/joshuazd/vim.git)

To be able to build from source, first run `./dotfiles/viminstall.sh`

Then, in the source directory, run `make && sudo make install`

## Build tmux from source

To build tmux from source, run `./dotfiles/tmuxinstall.sh`

## Misc Features

- The 256-colors.sh script will print out all 256 term colors, both as background and as foreground colors.

  Run it using `./256-colors.sh`


- The colortrans.py script will convert between hex codes and term colors.  
  It can also match hex codes to their nearest term color equivalent

  Run it using `python colortrans.py 23` or `python colortrans.py ff5370`
