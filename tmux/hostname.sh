hostname() {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  # shellcheck disable=SC2039
  # if [ x"$OSTYPE" = x"cygwin" ]; then
  #   pid=$(ps -a | awk -v tty="${tty##/dev/}" '$5 == tty && /ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ { print $1 }')
  #   [ -n "$pid" ] && ssh_parameters=$(tr '\0' ' ' < "/proc/$pid/cmdline" | sed 's/^ssh //')
  # else
  ssh_parameters=$(ps -t "$tty" -o command= | awk '/ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ { $1=""; print $0; exit }')
  ssh_parameters=$(echo "$ssh_parameters" | awk '{ if($1~/sshrc/) print $2; else print $0; }')
  if [ -n "$ssh_parameters" ]; then
    # shellcheck disable=SC2086
    hostname=$(ssh -G $ssh_parameters 2>/dev/null | awk 'NR > 2 { exit } ; /^hostname / { print $2 }')
    if [ "$hostname" = "localhost" ]; then
        hostname=$ssh_parameters
        hostname=$(echo "$hostname" | awk '
            {
                if ($1~/^[0-9.:]+$/)
                    print $1;
                else if ($1~/^[a-zA-Z0-9_.:]+@[a-zA-Z0-9_.:]+$/)
                    { split($1, a, "@"); print a[2]; }
                else
                    print $1;
                }')
    else
        [ -z "$hostname" ] && hostname=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%hostname%% %h >&2'" $ssh_parameters 2>&1 | awk '/^%hostname% / { print $2; exit }')
        hostname=$(echo "$hostname" | awk '\
            { \
                if ($1~/^[0-9.:]+$/) \
                    print $1; \
                else \
                    split($1, a, ".") ; print a[1] \
                }')
    fi
  else
      hostname=$(command hostname -s)
  fi

  echo "$hostname"
}
hostname
