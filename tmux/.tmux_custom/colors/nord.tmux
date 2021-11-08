# panes {{{
set -g pane-border-fg colour8
set -g pane-border-bg colour8
set -g pane-active-border-fg colour8
set -g pane-active-border-bg colour8
# }}}

# messaging
set -g message-style fg=colour46,bold,bg=colour232

#window mode {{{
set -g window-style bg=default
set -g window-active-style bg=default
# }}}

# The modes {{{
setw -g clock-mode-colour colour5
setw -g clock-mode-style 12
setw -g mode-attr bold
setw -g mode-fg colour13
setw -g mode-bg colour0
# }}}

# The statusbar {{{
set -g status-position bottom
set -g status-justify left
set -g status-bg colour8
set -g status-fg colour12
set -g status-left '#[fg=colour5,bold,bg=colour0] #S § '
set -g status-right '#{battery_status_fg}#{battery_percentage}#[fg=default]#{battery_remain}#[fg=colour4,nobold] %H:%M:%S#[bg=default,fg=colour3] #{username} #[fg=default]#{hostname} '

setw -g window-status-current-format '#[fg=colour4,bg=colour0] #I:#W#F '

setw -g window-status-fg colour7
setw -g window-status-bg colour8
setw -g window-status-format ' #I:#W#F '
setw -g window-status-separator ''

setw -g window-status-bell-attr bold
setw -g window-status-bell-fg colour255
setw -g window-status-bell-bg colour1

# }}}
run-shell "~/dotfiles/tmux/custom_tmux.sh"
