# panes {{{
set -g pane-border-fg '#45403a'
set -g pane-border-bg '#b4af9a'
set -g pane-border-format '│'
set -g pane-active-border-fg '#45403a'
set -g pane-active-border-bg '#b4af9a'
# }}}

# messaging
set -g message-style fg='#45403a',bold,bg='#999483'

#window mode {{{
# set -g window-style bg='#b4af9a'
# set -g window-active-style bg='#b4af9a'
# set -g window-style bg='#999483'
# }}}

# The modes {{{
setw -g clock-mode-colour colour5
setw -g clock-mode-style 12
setw -g mode-attr bold
setw -g mode-fg '#b4af9a'
setw -g mode-bg '#45403a'
# }}}

# The statusbar {{{
set -g status-position bottom
set -g status-justify left
set -g status-bg '#45403a'
set -g status-fg '#b4af9a'
set -g status-left ' #S § '
set -g status-right '#{battery_percentage}#{battery_remain}#[nobold] %H:%M:%S %P #{username} #{hostname} '

setw -g window-status-current-fg '#45403a'
setw -g window-status-current-bg '#b4af9a'
setw -g window-status-current-bg '#999483'

setw -g window-status-bg '#45403a'
setw -g window-status-fg '#b4af9a'
setw -g window-status-format ' #I:#W#F '
setw -g window-status-current-format ' #I:#W#F '
setw -g window-status-separator ''

setw -g window-status-bell-attr bold
setw -g window-status-bell-fg colour255
setw -g window-status-bell-bg colour1

# }}}
run-shell "$TMUX_CUSTOM/custom_tmux.sh"
