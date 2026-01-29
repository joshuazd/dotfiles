#!/usr/bin/env bash

tty=${1:-$(tmux display -p '#{pane_tty}')}
ssh_params=$(ps -t "$tty" -o command= | awk '/ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ {$1=""; print; exit}')

if [ -n "$ssh_params" ]; then
	# Extract username from SSH config
	username=$(ssh -G $ssh_params 2>/dev/null | awk 'NR > 2 {exit}; /^user / {print $2}')
	# Fallback: parse from SSH command
	[ -z "$username" ] && username=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%u %r >&2'" $ssh_params 2>&1 | awk '/^%u / {print $2; exit}')
else
	# Local session: get username of the shell process
	username=$(ps -t "$tty" -o user=,pid=,ppid=,command= | awk '!/ssh/ {u[$2]=$1; p[$3]=1} END {for(i in u) if(!(i in p)) {print u[i]; exit}}')
fi

echo "$username"
