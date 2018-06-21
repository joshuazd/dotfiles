#!/usr/bin/env zsh

verify_tmux_version () {

    if [[ `tmux -V | grep -oPm1 '\d+\.\d+'` -ge 2.2 ]] ; then
        tmux bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
        tmux bind -T copy-mode-vi v send -X begin-selection
        tmux bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
        tmux bind -T copy-mode-vi C-v send -X rectangle-toggle
        exit
    elif [[ `tmux -V | grep -oPm1 '\d+\.\d+'` -lt 1.9 ]] ; then
        tmux bind -t vi-copy Enter copy-pipe "xclip -i -f -selection primary | xclip -i -selection clipboard"
        tmux bind -t vi-copy v begin-selection
        tmux bind -t vi-copy y copy-pipe "xclip -i -f -selection primary | xclip -i -selection clipboard"
        tmux bind -t vi-copy C-v rectangle-toggle
        exit
    else
        exit
    fi
}

verify_tmux_version
