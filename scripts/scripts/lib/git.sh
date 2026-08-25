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

#######################################
# Print the repository directory a PR's review worktree should be cut from.
#
# A PR URL names its repository and the caller's working directory does not, so
# the URL wins: a worktree cut from the wrong repository has no such branch, and
# a review dispatched from a portal pane would otherwise always land in portal
# whatever repository the PR came from.
#
# Clones live at ${HOME}/<repo>, the same layout dispatch-from-chrome resolves
# its --repo flag against. A missing clone is an error rather than a fall back to
# the working directory, because that silent fall back is the defect itself.
#
# A bare PR number names no repository, so `gh pr view` resolves it against the
# caller's repo and the working directory is the only correct answer.
# Arguments:
#   PR number or URL
# Outputs:
#   Writes the repository directory to stdout
# Returns:
#   0 on success, 1 when the URL names a repo with no clone under ${HOME}
#######################################
pr_repo_dir() {
  local pr_ref="${1}"

  if [[ ! "${pr_ref}" =~ ^https?://[^/]*github\.com/[^/]+/([^/]+)/pull/ ]]; then
    printf "%s" "${PWD}"
    return 0
  fi

  local repo="${BASH_REMATCH[1]}"
  if [ ! -d "${HOME}/${repo}" ]; then
    error "PR ${pr_ref} lives in '${repo}', which has no clone at ${HOME}/${repo}"
    error "Clone it there and retry"
    return 1
  fi

  printf "%s" "${HOME}/${repo}"
}
