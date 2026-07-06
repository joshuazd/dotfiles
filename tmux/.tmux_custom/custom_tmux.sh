#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux_interpolation=(
	"\#{battery_percentage}"
	"\#{battery_status_fg}"
    "\#{battery_remain}"
    "\#{username}"
    "\#{hostname}"
)
# Route the expensive scripts through tmux_cache.sh so they recompute at most
# once every 30s instead of every status-interval (1s). Battery and the
# user/host probes (pmset / ps / ssh -G) are the costly forks; caching them
# cuts the per-second status-bar cost by ~10x with no visible change.
_C="$CURRENT_DIR/tmux_cache.sh 30"
tmux_commands=(
	"#($_C $CURRENT_DIR/battery_percentage.sh)"
	"#($_C $CURRENT_DIR/battery_color.sh)"
    "#($_C $CURRENT_DIR/battery_remain.sh)"
    "#($_C $CURRENT_DIR/username.sh #{pane_tty})"
    "#($_C $CURRENT_DIR/hostname.sh #{pane_tty})"
)

get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option="$1"
	local value="$2"
	tmux set-option -gq "$option" "$value"
}

do_interpolation() {
	local all_interpolated="$1"
	for ((i=0; i<${#tmux_commands[@]}; i++)); do
		all_interpolated=${all_interpolated//${tmux_interpolation[$i]}/${tmux_commands[$i]}}
	done
	echo "$all_interpolated"
}

update_tmux_option() {
	local option="$1"
	local option_value="$(get_tmux_option "$option")"
	local new_option_value="$(do_interpolation "$option_value")"
	set_tmux_option "$option" "$new_option_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}
main
