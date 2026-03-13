#!/usr/bin/env bash
#
# common.sh - Shared library for workflow scripts
#
# Provides output helpers, environment checks, git/tmux utilities, Shortcut
# data access, and the run_worktree_popup orchestration function.
#
# Usage:
#   source "${SCRIPT_DIR}/common.sh"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

#######################################
# Print error message to stderr
# Arguments:
#   Error message
# Outputs:
#   Writes error message to stderr
#######################################
error() {
  printf "${RED}!!! %s${RESET}\\n" "${*}" 1>&2
}

#######################################
# Print info message to stdout
# Arguments:
#   Info message
# Outputs:
#   Writes info message to stdout
#######################################
info() {
  printf "${GREEN}>>> %s${RESET}\\n" "${*}"
}

#######################################
# Print warning message to stdout
# Arguments:
#   Warning message
# Outputs:
#   Writes warning message to stdout
#######################################
warn() {
  printf "${YELLOW}!!! %s${RESET}\\n" "${*}"
}

#######################################
# Check if help is requested
# Arguments:
#   All script arguments
# Returns:
#   0 if help is wanted, 1 otherwise
#######################################
help_wanted() {
  [ "${#}" -ge 1 ] && { [ "${1}" = '-h' ] || [ "${1}" = '--help' ] || [ "${1}" = '-?' ]; }
}

#######################################
# Check if running inside tmux
# Returns:
#   0 if in tmux, 1 otherwise
#######################################
is_in_tmux() {
  [ -n "${TMUX:-}" ]
}

#######################################
# Check if current directory is in a git repository
# Returns:
#   0 if in a git repo, 1 otherwise
#######################################
is_git_repo() {
  git rev-parse --git-dir > /dev/null 2>&1
}

#######################################
# Strip everything before and including the first slash
# Arguments:
#   Branch name
# Outputs:
#   Writes directory/session name to stdout
#######################################
get_name_from_branch() {
  local branch_name="${1}"
  local name="${branch_name#*/}"

  printf "%s" "${name}"
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
# Extract story ID from Shortcut URL or ID string
# Strips whitespace, handles URLs, sc-<id>, and bare integers.
# Arguments:
#   Story URL or ID
# Outputs:
#   Writes numeric story ID to stdout
# Returns:
#   0 on success, 1 on invalid input
#######################################
extract_story_id() {
  local input
  input="$(printf '%s' "${1}" | tr -d '[:space:]')"
  local story_id

  if [[ "${input}" =~ https?:// ]]; then
    if [[ "${input}" =~ /story/([0-9]+) ]]; then
      story_id="${BASH_REMATCH[1]}"
    else
      error "Could not extract story ID from URL: ${input}"
      return 1
    fi
  elif [[ "${input}" =~ ^sc-([0-9]+)$ ]]; then
    story_id="${BASH_REMATCH[1]}"
  elif [[ "${input}" =~ ^[0-9]+$ ]]; then
    story_id="${input}"
  else
    error "Invalid story format: ${input}"
    error "Expected: URL, sc-12345, or 12345"
    return 1
  fi

  printf "%s" "${story_id}"
}

#######################################
# Normalize PR input: strip leading '#' if present
# Arguments:
#   PR number, #PR number, or URL
# Outputs:
#   Writes normalized input to stdout
#######################################
normalize_pr_input() {
  printf "%s" "${1#\#}"
}

#######################################
# Fetch story JSON from Shortcut
# Arguments:
#   story_id — numeric story ID
# Outputs:
#   Writes JSON to stdout
#######################################
fetch_story_json() {
  local story_id="${1}"
  local json_output

  if ! json_output="$(short story "${story_id}" --format "%j" 2>/dev/null)"; then
    error "Failed to fetch story ${story_id} from Shortcut"
    return 1
  fi

  printf "%s" "${json_output}"
}

#######################################
# Extract story title (.name) from story JSON
# Arguments:
#   json — story JSON string
# Outputs:
#   Writes title to stdout (empty if not found)
#######################################
title_from_json() {
  local json="${1}"
  local title

  if command -v jq > /dev/null 2>&1; then
    title="$(printf "%s" "${json}" | jq --raw-output '.name // empty')"
  else
    title="$(printf "%s" "${json}" | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"\([^"]*\)"/\1/' || true)"
  fi

  printf "%s" "${title}"
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
# Extract branch name from story JSON
# Arguments:
#   json — story JSON string
# Outputs:
#   Writes branch name to stdout
#######################################
branch_from_json() {
  local json="${1}"
  local branch_name

  if command -v jq > /dev/null 2>&1; then
    branch_name="$(printf "%s" "${json}" | jq --raw-output '.formatted_vcs_branch_name // empty')"
  else
    branch_name="$(printf "%s" "${json}" | grep -o '"formatted_vcs_branch_name":"[^"]*"' | sed 's/"formatted_vcs_branch_name":"\([^"]*\)"/\1/' || true)"
  fi

  if [ -z "${branch_name}" ]; then
    error "No branch name found in story"
    error "The story may not have a branch associated with it"
    return 1
  fi

  printf "%s" "${branch_name}"
}

#######################################
# Open a tmux popup to run git-worktree-session, then optionally switch to the new session
# Flags (any order, before or after positionals):
#   --detached            Skip the session switch after the popup
#   --non-interactive     Don't pause for Enter before the popup closes
#   --prefix <value>      Prepend value to session/dir name (default: "")
#   --fetch               Fetch from origin and reset to remote HEAD
#   --session-name <name> Override the tmux session name (default: branch-derived)
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
  local fetch=false
  local session_name_override=""
  local -a positionals=()

  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      --detached)        detached=true;              shift ;;
      --non-interactive) interactive=false;           shift ;;
      --prefix)          prefix="${2}";              shift 2 ;;
      --fetch)           fetch=true;                 shift ;;
      --session-name)    session_name_override="${2}"; shift 2 ;;
      *)                 positionals+=("${1}"); shift ;;
    esac
  done

  local current_dir="${positionals[0]}"
  local session_script="${positionals[1]}"
  local branch_name="${positionals[2]}"
  local session_name="${positionals[3]}"

  local prefix_flag=""
  if [ -n "${prefix}" ]; then
    prefix_flag="--prefix '${prefix}'"
  fi

  local fetch_flag=""
  if ${fetch}; then
    fetch_flag="--fetch"
  fi

  local session_name_flag=""
  if [ -n "${session_name_override}" ]; then
    session_name_flag="--session-name '${session_name_override}'"
  fi

  # The inner --detached tells git-worktree-session to create the tmux session
  # without attaching — required here because we're inside a popup. The outer
  # $detached variable controls whether *this* script switches the client after.
  local popup_command
  popup_command="cd '${current_dir}' && '${session_script}' --detached ${prefix_flag} ${fetch_flag} ${session_name_flag} '${branch_name}'"

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
