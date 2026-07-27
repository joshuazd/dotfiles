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

#######################################
# Check if running inside tmux
# Returns:
#   0 if in tmux, 1 otherwise
#######################################
is_in_tmux() {
  [ -n "${TMUX:-}" ]
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

  tmux respawn-pane -k -t "=${session_name}:claude.1" -c "${session_dir}" \
    "${command}; exec \"\${SHELL}\""
}

#######################################
# Split the claude window and run the given command in the new pane.
# Uses vertical split when terminal is wide enough, horizontal otherwise.
# Arguments:
#   $1 - session name
#   $2 - command to run in the new pane (e.g. "nit", "review")
#######################################
setup_secondary_pane() {
  local session="${1}"
  local pane_command="${2}"
  local target="=${session}:claude"
  local width
  width="$(tmux display-message -t "${target}" -p '#{window_width}')"

  if [ "${width}" -ge 200 ]; then
    tmux split-window -t "${target}" -h -c "#{pane_current_path}"
  else
    tmux split-window -t "${target}" -v -c "#{pane_current_path}"
  fi

  tmux send-keys -t "${target}.2" "${pane_command}" Enter
  tmux select-pane -t "${target}.1"
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
#   0 on success
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
      if is_in_tmux; then
        tmux switch-client -t "=${session_name}"
      else
        tmux attach-session -t "=${session_name}"
      fi
    fi
    return 0
  fi

  info "Creating tmux session '${session_name}' in ${session_dir}"

  # All paths create detached first so we can set up panes before attaching
  tmux new-session -d -s "${session_name}" -n "claude" -c "${session_dir}"
  tmux new-window -t "=${session_name}:2" -n "server" -c "${session_dir}"
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
  elif is_in_tmux; then
    info "Switching to session '${session_name}'"
    tmux switch-client -t "=${session_name}"
  else
    tmux attach-session -t "=${session_name}"
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
#   0 on success
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

  if ${interactive}; then
    popup_command+="; printf '\\n${BLUE}Press Enter to close...${RESET}'; read -r"
  fi

  if [ "${DISPATCH_IN_POPUP:-}" = "1" ]; then
    bash -c "${popup_command}"
  else
    tmux display-popup -E -w 80% -h 60% "${popup_command}"
  fi

  if ! ${detached}; then
    info "Switching to session '${session_name}'"
    tmux switch-client -t "=${session_name}"
  fi
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
