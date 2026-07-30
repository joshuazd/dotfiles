#!/usr/bin/env bash
#
# lib/tmux.sh - Tmux session management and worktree popup orchestration
#
# Usage:
#   source "${SCRIPT_DIR}/lib/tmux.sh"

[[ -n "${__LIB_TMUX_LOADED:-}" ]] && return
readonly __LIB_TMUX_LOADED=1

_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_lib_dir}/output.sh"
source "${_lib_dir}/git.sh"
source "${_lib_dir}/shortcut.sh"
unset _lib_dir

# Exit status meaning "the tmux session was already there". create_tmux_session
# reports it, git-worktree-session and run_worktree_popup carry it out through
# the popup, and callers use it to skip launching Claude: respawn-pane -k would
# SIGKILL the Claude already running in that pane, mid-turn.
readonly SESSION_EXISTED=3

#######################################
# Check if running inside tmux
# Returns:
#   0 if in tmux, 1 otherwise
#######################################
is_in_tmux() {
  [ -n "${TMUX:-}" ]
}

#######################################
# Report whether a tmux server can be reached, starting one if needed.
#
# Distinct from is_in_tmux, which asks whether *this process* is inside a tmux
# client. A daemon-run dispatch is not, and has no business being refused for
# it: it creates sessions through tmux commands, which need a server, not a
# $TMUX.
# Returns:
#   0 if tmux is usable, 1 otherwise
#######################################
tmux_reachable() {
  command -v tmux > /dev/null 2>&1 || return 1
  tmux start-server > /dev/null 2>&1
}

#######################################
# Switch a client to a target, naming the client when one was given.
#
# Never attaches. A daemon-run job has no terminal, and tmux attach-session
# from one would block until the job's timeout rather than failing.
# Arguments:
#   target - a tmux target, e.g. "=SC-1 demo:claude"
# Returns:
#   0 on success, non-zero if tmux refused
#######################################
switch_client_to() {
  local target="${1}"
  if [ -n "${VIGIL_CLIENT:-}" ]; then
    tmux switch-client -c "${VIGIL_CLIENT}" -t "${target}"
    return "${?}"
  fi
  tmux switch-client -t "${target}"
}

#######################################
# Switch a client to a target, warning instead of failing when it cannot.
#
# Every workflow script runs under `set -o errexit` and calls this at the very
# end, once the worktree, the session and Claude all exist. A bare
# switch-client there aborts the script on failure, and a daemon-run job is
# then recorded as failed with whatever stale line it last printed - reporting
# a completely successful dispatch as a failure. It used to be unreachable: the
# switch ran inside a popup, which by definition has a current client. A
# daemon-run job does not: VIGIL_CLIENT is resolved when the job starts and
# names a client that can detach during the minute the job takes, and the
# target window can be gone by then too.
#
# Fails soft the way add_vigil_panel already does. The session is created
# either way, and the user can reach it themselves.
# Arguments:
#   target - a tmux target, e.g. "=SC-1 demo:claude"
# Returns:
#   0 always
#######################################
teleport_client_to() {
  local target="${1}"
  switch_client_to "${target}" \
    || warn "Could not switch to '${target}'; it was created and is waiting"
  return 0
}

#######################################
# Build a tmux-safe session name from a prefix, ID, and title
# Strips colons and periods (break tmux targeting), truncates to ~50 chars
# at a word boundary.
# Arguments:
#   prefix — e.g. "SC" or "PR"
#   id     — e.g. "190583" or "4521"
#   title  — e.g. "Emit Datadog metrics: for investigation"
# Outputs:
#   e.g. "SC-190583 Emit Datadog metrics for investigation"
#######################################
session_name_from_title() {
  local prefix="${1}"
  local id="${2}"
  local title="${3}"

  # Strip tmux-unsafe characters
  title="${title//:/}"
  title="${title//./}"
  title="${title//\'/}"

  local head="${prefix}-${id} "
  local max_title_len=$(( 50 - ${#head} ))

  if [ "${#title}" -gt "${max_title_len}" ]; then
    # Truncate at word boundary
    local truncated="${title:0:${max_title_len}}"
    # Remove partial trailing word
    if [ "${title:${max_title_len}:1}" != " " ] && [ "${title:${max_title_len}:1}" != "" ]; then
      truncated="${truncated% *}"
    fi
    title="${truncated}"
  fi

  printf "%s" "${head}${title}"
}

#######################################
# Print a tmux target for a session's claude pane.
# Resolved by the @vigil_claude marker rather than by position: panels are
# inserted with split-window -b, before the existing pane, and tmux pane
# indexes are positional, so .1 stops meaning "the claude pane" the moment a
# window gains a panel. Falls back to the positional target for sessions
# created before the marker existed.
# Arguments:
#   session_name
# Outputs:
#   a pane id (e.g. %5) or "=<session>:claude.1"
#######################################
claude_pane_target() {
  local session_name="${1}"
  local pane
  pane="$(tmux list-panes -t "=${session_name}:claude" -F '#{pane_id} #{@vigil_claude}' 2>/dev/null \
    | awk '$2 == "1" { print $1; exit }')" || pane=""
  if [ -n "${pane}" ]; then
    printf '%s' "${pane}"
    return 0
  fi
  printf '%s' "=${session_name}:claude.1"
}

readonly VIGIL_PANEL_FLAG='@vigil_panel'

#######################################
# Print the height and width of a tmux client.
#
# Factored out because three callers depend on it agreeing with itself:
# panel_geometry sizes the panel against the client, create_tmux_session sizes
# the window it will be split into against the same client, and a daemon-run
# dispatch has no client of its own and must be told which one to measure.
# Two copies of the query could disagree about what "no client" looks like, and
# a panel sized for one window and split into another is exactly the bug this
# guards.
#
# A named client that cannot be measured falls back to measuring whatever
# client is available, and warns. Yielding nothing instead is the failure this
# guards: create_tmux_session then omits -x/-y, tmux sizes the window to
# default-size 80x24, and a 40-column panel is half of it - arriving at ~175
# columns when a 350-column client attaches. That is verbatim the balloon the
# previous phase closed, and a silent -c failure reinstated it with no signal
# at all. VIGIL_CLIENT is resolved when a job starts and the client can detach
# before the job's last line, so this is reachable in ordinary use.
#
# Arguments:
#   client - optional client name; defaults to ${VIGIL_CLIENT}, then to the
#            calling client
# Outputs:
#   e.g. "90 350", or " " with no client at all
#######################################
client_dimensions() {
  local client="${1:-${VIGIL_CLIENT:-}}"
  local dims=""
  if [ -n "${client}" ]; then
    dims="$(tmux display-message -c "${client}" -p '#{client_height} #{client_width}' 2>/dev/null)" || dims=""
    # Whitespace-stripped: tmux answers a client it cannot size with a bare
    # space, which read splits into two empty fields exactly as an error does.
    if [ -n "${dims// /}" ]; then
      printf '%s\n' "${dims}"
      return 0
    fi
    warn "Could not measure tmux client '${client}'; falling back to the current client"
  fi
  tmux display-message -p '#{client_height} #{client_width}' 2>/dev/null
}

#######################################
# Print the split flag and size for the current client.
# Portrait (a vertical monitor) gets a wide strip across the top; anything
# else gets a narrow column on the left.
#
# Geometry is configured with tmux user options rather than vigil's config,
# because placement is tmux's concern and these functions are its only reader:
#   @vigil_panel_orientation  auto (default) | top | left
#   @vigil_panel_size         rows for top (default 10), columns for left (40)
# Outputs:
#   e.g. "-hb 40"
#######################################
panel_geometry() {
  local orientation size height width
  orientation="$(tmux show-options -gqv "@vigil_panel_orientation")"
  size="$(tmux show-options -gqv "@vigil_panel_size")"
  read -r height width <<< "$(client_dimensions)"

  if [ -z "${orientation}" ] || [ "${orientation}" = "auto" ]; then
    if [ -z "${height:-}" ] || [ -z "${width:-}" ]; then
      # No client attached, which is every session created detached. The
      # arithmetic below is a fatal error on an empty string, not a wrong
      # answer, so this branch has to come first.
      orientation="left"
    elif [ "$((height * 2))" -gt "${width}" ]; then
      orientation="top"
    else
      orientation="left"
    fi
  fi

  case "${orientation}" in
    top) printf '%s %s\n' '-vb' "${size:-10}" ;;
    *)   printf '%s %s\n' '-hb' "${size:-40}" ;;
  esac
}

#######################################
# Split a vigil panel into the given window and mark the new pane.
# Arguments:
#   window_target — e.g. "=SC-1 demo:claude"
# Returns:
#   0 on success, 1 if the split failed
#######################################
add_vigil_panel() {
  local window_target="${1}"
  local split size pane dir
  read -r split size <<< "$(panel_geometry)"

  # split-window with no -c inherits the *calling client's* working directory,
  # not the target window's. create_tmux_session runs inside the dispatch popup,
  # whose cwd is the main repository, so the panel landed there while the
  # session's work sat in a worktree. vigil then read git state from the panel's
  # directory and asked gh for the main branch's PR, which does not exist.
  #
  # Fail soft: a window that cannot be queried still gets a panel, just without
  # an explicit directory. Losing the panel would be worse than losing its cwd.
  dir="$(tmux display-message -p -t "${window_target}" '#{pane_current_path}' 2>/dev/null)" || dir=""

  # Checked explicitly rather than left to errexit: callers invoke this on the
  # left of ||, which disables errexit for the whole function, and a fallen
  # through failure would run set-option against an empty pane id.
  pane="$(tmux split-window -t "${window_target}" ${dir:+-c "${dir}"} "${split}" -l "${size}" \
    -d -P -F '#{pane_id}' "${VIGIL_BIN:-vigil} --panel")" || return 1
  [ -n "${pane}" ] || return 1

  tmux set-option -p -t "${pane}" "${VIGIL_PANEL_FLAG}" 1
  # So a dead panel closes its pane instead of leaving a corpse in the layout.
  tmux set-option -p -t "${pane}" remain-on-exit off
}

#######################################
# Replace the claude pane's process with the given command.
# Uses respawn-pane rather than send-keys so there is no shell-readiness race
# and the command never passes through a shell prompt. Appends an exec of the
# login shell so exiting Claude leaves a usable pane instead of collapsing it.
# Arguments:
#   session_name - tmux session name
#   session_dir  - working directory for the pane
#   command      - command to run
#######################################
launch_claude_in_pane() {
  local session_name="${1}"
  local session_dir="${2}"
  local command="${3}"
  local target
  target="$(claude_pane_target "${session_name}")"

  tmux respawn-pane -k -t "${target}" -c "${session_dir}" \
    "${command}; exec \"\${SHELL}\""
}

#######################################
# Split the claude window and run the given command in the new pane.
# Splits horizontally when the claude pane itself is at least 200 columns,
# vertically otherwise. The pane, not the window: a vigil panel takes 40
# columns off the pane without changing window_width.
# Arguments:
#   $1 - session name
#   $2 - command to run in the new pane (e.g. "nit", "review")
#######################################
setup_secondary_pane() {
  local session="${1}"
  local pane_command="${2}"
  local claude_pane width split new_pane
  claude_pane="$(claude_pane_target "${session}")"
  width="$(tmux display-message -t "${claude_pane}" -p '#{pane_width}')"

  if [ "${width}" -ge 200 ]; then
    split='-h'
  else
    split='-v'
  fi

  new_pane="$(tmux split-window -t "${claude_pane}" "${split}" -c '#{pane_current_path}' -P -F '#{pane_id}')"
  tmux send-keys -t "${new_pane}" "${pane_command}" Enter
  tmux select-pane -t "${claude_pane}"
}

#######################################
# Create a tmux session with the standard 2-window layout (claude + server)
# If a session with the given name already exists, switches to it instead.
# Arguments:
#   session_name   — tmux session name
#   session_dir    — directory to open in
#   detached       — "true" to skip switching, "false" to attach/switch
#   pane_command   — command for the split pane (empty = no split; default: nit)
#   claude_command — command to run in the claude window (empty = none; default: none)
# Returns:
#   0 on success, SESSION_EXISTED if the session was already there
#######################################
create_tmux_session() {
  local session_name="${1}"
  local session_dir="${2}"
  local detached="${3:-false}"
  local pane_command="${4-nit}"
  local claude_command="${5-}"

  # If session already exists, just switch to it
  if tmux has-session -t "=${session_name}" 2>/dev/null; then
    info "Session '${session_name}' already exists"
    if ! ${detached}; then
      teleport_client_to "=${session_name}"
    fi
    return "${SESSION_EXISTED}"
  fi

  info "Creating tmux session '${session_name}' in ${session_dir}"

  # All paths create detached first so we can set up panes before attaching.
  # A detached session has no client, so tmux sizes its windows to
  # default-size (80x24) and then redistributes panes proportionally when a
  # client finally lands on it. Panels are split at an absolute column count,
  # so a 40-column panel in an 80-column window is half of it, and arrives at
  # ~175 columns on a 350-column client. Creating the window at the calling
  # client's size makes the split land where panel_geometry meant it to.
  #
  # The flags are omitted entirely when there is no client to measure — a
  # cron or Chrome dispatch from outside tmux — which leaves session creation
  # exactly as it was.
  local -a size_flags=()
  local client_height client_width
  read -r client_height client_width <<< "$(client_dimensions)"
  if [ -n "${client_height}" ] && [ -n "${client_width}" ]; then
    size_flags=(-x "${client_width}" -y "${client_height}")
  fi
  tmux new-session -d -s "${session_name}" -n "claude" -c "${session_dir}" \
    ${size_flags[@]+"${size_flags[@]}"}
  # Mark the pane so later targeting does not depend on its index, which
  # shifts when a panel is inserted before it.
  tmux set-option -p -t "=${session_name}:claude" @vigil_claude 1
  tmux new-window -t "=${session_name}:2" -n "server" -c "${session_dir}"
  # ${VIGIL_BIN:-vigil}, matching add_vigil_panel: a dev build pointed at by
  # VIGIL_BIN must gate the same binary it launches.
  #
  # command -v first, so an absent vigil is silent (no panel, nothing to say)
  # while a present one that errors is warned about. Folding the two together
  # under 2>/dev/null left a user mid-upgrade with no panel and no
  # explanation, which is indistinguishable from panel_auto = false.
  local vigil_bin panel_auto
  vigil_bin="${VIGIL_BIN:-vigil}"
  if command -v "${vigil_bin}" > /dev/null 2>&1; then
    if ! panel_auto="$("${vigil_bin}" config get panel_auto)"; then
      warn "vigil config get panel_auto failed"
      panel_auto=""
    fi
    if [ "${panel_auto}" = "true" ]; then
      # Before setup_secondary_pane, so that split measures a pane the panel
      # has already narrowed. Fail-soft: a panel that cannot be created must
      # never take the session with it.
      add_vigil_panel "=${session_name}:claude" || warn "vigil panel failed"
    fi
  fi
  if [ -n "${pane_command}" ]; then
    setup_secondary_pane "${session_name}" "${pane_command}"
  fi
  if [ -n "${claude_command}" ]; then
    launch_claude_in_pane "${session_name}" "${session_dir}" "${claude_command}"
  fi
  tmux select-window -t "=${session_name}:1"

  if ${detached}; then
    info "Detached session '${session_name}' created"
    info "To attach: tmux attach-session -t '=${session_name}'"
  else
    info "Switching to session '${session_name}'"
    teleport_client_to "=${session_name}"
  fi

  return 0
}

#######################################
# Print a Shortcut-derived session name if the branch references a story
# Arguments:
#   branch_name
# Outputs:
#   Writes session name to stdout when resolved
# Returns:
#   0 if a name was printed, 1 otherwise
#######################################
_resolve_story_name() {
  local branch_name="${1}"
  [[ "${branch_name}" =~ [Ss][Cc]-([0-9]+) ]] || return 1
  local story_id="${BASH_REMATCH[1]}"
  command -v short > /dev/null 2>&1 || return 1

  local summary story_title
  summary="$(fetch_story_summary "${story_id}" 2>/dev/null)" || return 1
  story_title="${summary%%$'\t'*}"
  [ -n "${story_title}" ] || return 1

  session_name_from_title "SC" "${story_id}" "${story_title}"
}

#######################################
# Print a GitHub PR-derived session name if the branch has an open PR
# gh runs inside the worktree so it resolves the right repo.
# Arguments:
#   dir          — absolute path to the worktree
#   branch_name  — branch to look the PR up by
# Outputs:
#   Writes session name to stdout when resolved
# Returns:
#   0 if a name was printed, 1 otherwise
#######################################
_resolve_pr_name() {
  local dir="${1}"
  local branch_name="${2}"
  command -v gh > /dev/null 2>&1 || return 1

  local pr_json
  pr_json="$(cd "${dir}" && gh pr view "${branch_name}" --json number,title 2>/dev/null)" || return 1

  local pr_number pr_title
  pr_number="$(printf "%s" "${pr_json}" | jq -r '.number // empty' 2>/dev/null)"
  pr_title="$(printf "%s" "${pr_json}" | jq -r '.title // empty' 2>/dev/null)"
  [ -n "${pr_number}" ] && [ -n "${pr_title}" ] || return 1

  session_name_from_title "PR" "${pr_number}" "${pr_title}"
}

#######################################
# Resolve a smart session name for a directory
# Priority: dir-prefix-aware (pr- → PR first, else Shortcut first) >
#           prettified branch > dir basename
# Arguments:
#   dir — absolute path to the directory
# Outputs:
#   Writes session name to stdout
#######################################
resolve_session_name() {
  local dir="${1}"
  local branch_name

  # Not a git repo — use directory basename
  if ! branch_name="$(git -C "${dir}" symbolic-ref --quiet --short HEAD 2>/dev/null)"; then
    printf "%s" "$(basename "${dir}")"
    return 0
  fi

  # PR worktree dirs are prefixed with pr- — prefer the PR title for those,
  # even if the branch also references a Shortcut story.
  if [[ "$(basename "${dir}")" == pr-* ]]; then
    _resolve_pr_name "${dir}" "${branch_name}" && return 0
    _resolve_story_name "${branch_name}" && return 0
  else
    _resolve_story_name "${branch_name}" && return 0
    _resolve_pr_name "${dir}" "${branch_name}" && return 0
  fi

  # Prettified branch name
  printf "%s" "$(get_name_from_branch "${branch_name}")"
}

#######################################
# Resolve path to git-worktree-session and verify it is executable
# Arguments:
#   Directory containing git-worktree-session
# Outputs:
#   Writes resolved script path to stdout
# Returns:
#   0 on success, 1 if not found or not executable
#######################################
resolve_session_script() {
  local script_dir="${1}"
  local session_script="${script_dir}/git-worktree-session"

  if [ ! -x "${session_script}" ]; then
    error "git-worktree-session script not found or not executable: ${session_script}"
    return 1
  fi

  printf "%s" "${session_script}"
}

#######################################
# Open a tmux popup to run git-worktree-session, then optionally switch to the new session
# Flags (any order, before or after positionals):
#   --detached            Skip the session switch after the popup
#   --non-interactive     Don't pause for Enter before the popup closes
#   --prefix <value>      Prepend value to session/dir name (default: "")
#   --dir-name <name>     Override the directory name entirely
#   --fetch               Fetch from origin and reset to remote HEAD
#   --session-name <name> Override the tmux session name (default: branch-derived)
#   --pane-command <cmd>  Command to run in the split pane (empty = no split; default: nit)
# Positional arguments:
#   current_dir    — working directory to cd into inside the popup
#   session_script — absolute path to git-worktree-session
#   branch_name    — branch to pass to git-worktree-session
#   session_name   — tmux session name to switch to afterwards
# Returns:
#   0 on success, SESSION_EXISTED if the session was already there (the switch
#   still happens), otherwise the popup command's own failing status
#######################################
run_worktree_popup() {
  local detached=false
  local interactive=true
  local prefix=""
  local dir_name_override=""
  local fetch=false
  local session_name_override=""
  local pane_command=""
  local pane_command_set=false
  local -a positionals=()

  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      --detached)        detached=true;              shift ;;
      --non-interactive) interactive=false;           shift ;;
      --prefix)          prefix="${2}";              shift 2 ;;
      --dir-name)        dir_name_override="${2}";   shift 2 ;;
      --fetch)           fetch=true;                 shift ;;
      --session-name)    session_name_override="${2}"; shift 2 ;;
      --pane-command)    pane_command="${2}"; pane_command_set=true; shift 2 ;;
      *)                 positionals+=("${1}"); shift ;;
    esac
  done

  local current_dir="${positionals[0]}"
  local session_script="${positionals[1]}"
  local branch_name="${positionals[2]}"
  local session_name="${positionals[3]}"

  local -a session_args=("--detached")
  if [ -n "${prefix}" ]; then
    session_args+=("--prefix" "${prefix}")
  fi
  if [ -n "${dir_name_override}" ]; then
    session_args+=("--dir-name" "${dir_name_override}")
  fi
  if ${fetch}; then
    session_args+=("--fetch")
  fi
  if [ -n "${session_name_override}" ]; then
    session_args+=("--session-name" "${session_name_override}")
  fi
  if ${pane_command_set}; then
    session_args+=("--pane-command" "${pane_command}")
  fi
  session_args+=("${branch_name}")

  # The inner --detached tells git-worktree-session to create the tmux session
  # without attaching — required here because we're inside a popup. The outer
  # $detached variable controls whether *this* script switches the client after.
  #
  # Use printf '%q' to safely escape all values for shell evaluation, since the
  # command string is passed to bash -c or tmux display-popup -E.
  local popup_command
  popup_command="cd $(printf '%q' "${current_dir}") && $(printf '%q' "${session_script}")"
  local arg
  for arg in "${session_args[@]}"; do
    popup_command+=" $(printf '%q' "${arg}")"
  done

  # The prompt must not swallow git-worktree-session's exit status: the caller
  # needs it to tell "session created" from SESSION_EXISTED.
  if ${interactive}; then
    popup_command+="; __popup_status=\${?}"
    popup_command+="; printf '\\n${BLUE}Press Enter to close...${RESET}'; read -r"
    popup_command+="; exit \"\${__popup_status}\""
  fi

  # tmux display-popup -E exits with the popup command's status, so the status
  # survives the popup boundary on both paths.
  local popup_status=0
  # DISPATCH_INLINE means "do not open a popup, run it here". Set by
  # dispatch-from-chrome's popup ancestor historically, and by a vigild job
  # today - a daemon is not a popup, which is why this is no longer called
  # DISPATCH_IN_POPUP.
  if [ "${DISPATCH_INLINE:-}" = "1" ]; then
    bash -c "${popup_command}" || popup_status="${?}"
  else
    tmux display-popup -E -w 80% -h 60% "${popup_command}" || popup_status="${?}"
  fi

  if [ "${popup_status}" -ne 0 ] && [ "${popup_status}" -ne "${SESSION_EXISTED}" ]; then
    return "${popup_status}"
  fi

  if ! ${detached}; then
    info "Switching to session '${session_name}'"
    teleport_client_to "=${session_name}"
  fi

  return "${popup_status}"
}

#######################################
# Print the path to a session's Claude launch-prompt file.
# Lives in the worktree's private git directory so it never shows up in
# git status, cannot be committed, and is removed with the worktree.
# Arguments:
#   session_name - tmux session name
# Outputs:
#   Writes the absolute file path to stdout
# Returns:
#   0 on success, 1 if the session or its git dir cannot be resolved
#######################################
worktree_prompt_file() {
  local session_name="${1}"
  local pane_path git_dir

  pane_path="$(tmux display-message -p -t "=${session_name}:claude" \
    '#{pane_current_path}' 2>/dev/null)" || return 1
  [ -n "${pane_path}" ] || return 1

  git_dir="$(git -C "${pane_path}" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  [ -n "${git_dir}" ] || return 1

  printf '%s/vigil-launch-prompt.txt' "${git_dir}"
}
