#!/usr/bin/env bash

tty=${1:-$(tmux display -p '#{pane_tty}')}
ssh_params=$(ps -t "$tty" -o command= | awk '/ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ {$1=""; print; exit}')

if [ -n "$ssh_params" ]; then
	# Get hostname from SSH config
	hostname=$(ssh -G $ssh_params 2>/dev/null | awk 'NR > 2 {exit}; /^hostname / {print $2}')
	
	# If hostname is localhost, extract from SSH params
	if [ "$hostname" = "localhost" ]; then
		hostname=$(echo "$ssh_params" | awk '{
			if($1~/^[0-9.:]+$/) print $1;
			else if($1~/^[a-zA-Z0-9_.:]+@[a-zA-Z0-9_.:]+$/) {split($1,a,"@"); print a[2]}
			else print $1
		}')
	else
		# Fallback: probe SSH connection
		[ -z "$hostname" ] && hostname=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%h %h >&2'" $ssh_params 2>&1 | awk '/^%h / {print $2; exit}')
		# Strip domain if present
		hostname=$(echo "$hostname" | awk '{if($1~/^[0-9.:]+$/) print $1; else {split($1,a,"."); print a[1]}}')
	fi
else
	# Local session
	hostname=$(hostname -s)
fi

echo "$hostname"
