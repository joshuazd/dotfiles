username() {
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
    username=$(ssh -G $ssh_parameters 2>/dev/null | awk 'NR > 2 { exit } ; /^user / { print $2 }')
    # shellcheck disable=SC2086
    [ -z "$username" ] && username=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%username%% %r >&2'" $ssh_parameters 2>&1 | awk '/^%username% / { print $2; exit }')
  else
      # shellcheck disable=SC2039
        username=$(ps -t "$tty" -o user= -o pid= -o ppid= -o command= | awk '
          !/ssh/ { user[$2] = $1; ppid[$3] = 1 }
          END {
            for (i in user)
              if (!(i in ppid))
              {
                print user[i]
                exit
              }
          }
        ')
    fi

  echo "$username"
}
username
