#!/usr/bin/env bash
#
# Cache the stdout of a command for <ttl> seconds, keyed by the command line.
#
#   Usage: tmux_cache.sh <ttl_seconds> <command> [args...]
#
# Used to throttle expensive tmux status-bar scripts. The status bar redraws
# every status-interval (1s) and re-runs each #() command; wrapping a script
# here makes it actually execute at most once per <ttl>, serving the cached
# output in between. Reduces per-second status cost from a full re-run (pmset,
# ps, ssh -G probes) to a couple of cheap stat/cat forks.

ttl="$1"; shift
[ -z "$1" ] && exit 0

cache_dir="${TMPDIR:-/tmp}/tmux-status-cache"

# Key on the full command line, sanitized to a safe filename (no fork).
key="${*//[^A-Za-z0-9]/_}"
cache_file="$cache_dir/$key"

# Serve from cache while it is younger than ttl. Hot path uses only one fork
# (stat): EPOCHSECONDS and $(<file) are bash builtins, so no date/cat spawn.
if [[ -f $cache_file ]]; then
	mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
	# EPOCHSECONDS is a bash 5.0+ builtin; empty under macOS system bash 3.2.
	now=${EPOCHSECONDS:-$(date +%s)}
	if [[ -n $mtime && $(( now - mtime )) -lt $ttl ]]; then
		printf '%s' "$(<"$cache_file")"
		exit 0
	fi
fi

# Stale or missing: recompute, store atomically, emit.
mkdir -p "$cache_dir" 2>/dev/null
out="$("$@" 2>/dev/null)"
printf '%s' "$out" > "$cache_file.$$" 2>/dev/null && mv "$cache_file.$$" "$cache_file" 2>/dev/null
printf '%s' "$out"
