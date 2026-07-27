####################################
# ZSH ENV - SOURCED BY EVERY ZSH
####################################
# Login and interactive shells already build their environment the existing
# way (.zprofile -> .profile, then .zshrc), so this file returns immediately
# for them and is only doing work for a non-interactive, non-login shell:
# `zsh -c ...`. That shell sources nothing else at all, and the ones that
# matter here are started by `tmux respawn-pane`, which runs the command under
# default-shell -c with the tmux *server's* environment, frozen at server
# start.

# Machine-local exports, untracked. Sourced for every zsh rather than only the
# non-interactive ones, because anything that has to reach a `zsh -c` (test
# runners, editors) generally has to reach an interactive shell too.
[ -f "${HOME}/.zshenv.local" ] && . "${HOME}/.zshenv.local"

if [[ -o interactive ]] || [[ -o login ]]; then
  return
fi

# .profile prepends with PATH=...:$PATH, so sourcing it twice duplicates every
# entry. $HOME/.bin is the sentinel: nothing else adds it, so its presence
# means a login shell (or an outer zsh -c) already assembled PATH.
case ":${PATH}:" in
  *":${HOME}/.bin:"*) ;;
  *) [ -f "${HOME}/.profile" ] && . "${HOME}/.profile" ;;
esac

# HOMEBREW_PREFIX is brew shellenv's own marker, so it doubles as the guard.
if [[ -z "${HOMEBREW_PREFIX:-}" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Mise via its shims, not `mise activate`: activation works by installing a
# precmd hook, which never fires without a prompt, so a non-interactive shell
# would keep whatever tool versions the inherited PATH froze in (tmux's
# environment carries entries like .../mise/installs/node/<version>/bin from
# whatever directory the server was started in). A shim resolves the version
# at exec time from the process's cwd, which respawn-pane -c sets to the
# worktree, so the worktree's pins win.
_mise_shims="${MISE_DATA_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/mise}/shims"
if [[ -d "${_mise_shims}" ]]; then
  case ":${PATH}:" in
    *":${_mise_shims}:"*) ;;
    *) export PATH="${_mise_shims}:${PATH}" ;;
  esac
fi
unset _mise_shims
