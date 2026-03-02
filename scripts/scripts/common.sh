#!/usr/bin/env bash
#
# common.sh - Shared functions for git worktree scripts
#
# This file contains common functions used by multiple git worktree scripts.
# Source this file in your scripts to use these functions.
#
# Usage:
#   source "${HOME}/scripts/common.sh"

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
# Open a tmux popup to run git-worktree-session, then optionally switch to the new session
# Arguments:
#   current_dir    — working directory to cd into inside the popup
#   session_script — absolute path to git-worktree-session
#   branch_name    — branch to pass to git-worktree-session
#   session_name   — tmux session name to switch to afterwards
#   detached       — "true" to skip the session switch
#   interactive    — "true" to pause for Enter before the popup closes
# Returns:
#   0 on success
#######################################
run_worktree_popup() {
  local current_dir="${1}"
  local session_script="${2}"
  local branch_name="${3}"
  local session_name="${4}"
  local detached="${5}"
  local interactive="${6}"
  local prefix="${7:-}"

  local prefix_flag=""
  if [ -n "${prefix}" ]; then
    prefix_flag="--prefix '${prefix}'"
  fi

  local popup_command
  popup_command="cd '${current_dir}' && '${session_script}' --detached ${prefix_flag} '${branch_name}'"

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
    tmux switch-client -t "${session_name}"
  fi
}

