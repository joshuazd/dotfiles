#!/usr/bin/env bash
#
# lib/git.sh - Git and branch/input parsing utilities
#
# Usage:
#   source "${SCRIPT_DIR}/lib/git.sh"

[[ -n "${__LIB_GIT_LOADED:-}" ]] && return
readonly __LIB_GIT_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

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
