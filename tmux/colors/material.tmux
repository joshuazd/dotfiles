# panes {{{
set -g pane-border-fg colour8
set -g pane-border-bg colour235
set -g pane-active-border-fg colour8
set -g pane-active-border-bg colour235
# }}}

# messaging
set -g message-style fg=colour46,bold,bg=colour232

#window mode {{{
set -g window-style bg=default
set -g window-active-style bg=default
# }}}

# The modes {{{
setw -g clock-mode-colour colour135
setw -g clock-mode-style 12
setw -g mode-attr bold
setw -g mode-fg colour135
setw -g mode-bg colour237
# }}}

# The statusbar {{{
set -g status-position bottom
set -g status-justify left
set -g status-bg colour236
set -g status-fg colour245
set -g status-left ' #[fg=colour248]#S § '
set -g status-right '#{battery_status_fg}#{battery_percentage}#[fg=default]#{battery_remain}#[fg=colour68,nobold] %H:%M:%S#[bg=default,fg=colour179] #{username} #[fg=default]#{hostname} '

setw -g window-status-current-fg colour234
setw -g window-status-current-bg colour167

setw -g window-status-fg colour248
setw -g window-status-bg colour236
setw -g window-status-format ' #I:#W#F '
setw -g window-status-current-format ' #I:#W#F '
setw -g window-status-separator ''

setw -g window-status-bell-attr bold
setw -g window-status-bell-fg colour255
setw -g window-status-bell-bg colour1

# }}}
run-shell "~/dotfiles/tmux/custom_tmux.sh"
