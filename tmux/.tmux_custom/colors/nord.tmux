# Panes
set -g pane-border-style fg=colour8,bg=colour8
set -g pane-active-border-style fg=colour8,bg=colour8

# Messaging
set -g message-style fg=colour46,bold,bg=colour232

# Window Mode
set -g window-style bg=default
set -g window-active-style bg=default

# Modes
setw -g clock-mode-colour colour5
setw -g clock-mode-style 12
setw -g mode-style fg=colour13,bg=colour0,bold

# Statusbar
set -g status-position bottom
set -g status-justify left
set -g status-bg colour8
set -g status-fg colour12
set -g status-left '#[fg=colour5,bold,bg=colour0] #S § '
set -g status-right '#{battery_status_fg}#{battery_percentage}#[fg=default]#[fg=colour4,nobold] %H:%M:%S#[bg=default,fg=colour3] #{username} #[fg=default]#{hostname} '

setw -g window-status-current-format '#[fg=colour4,bg=colour0] #I:#W#F '
setw -g window-status-style fg=colour7,bg=colour8
setw -g window-status-format ' #I:#W#F '
setw -g window-status-separator ''
setw -g window-status-bell-style fg=colour255,bg=colour1,bold

run-shell "$TMUX_CUSTOM/custom_tmux.sh"
