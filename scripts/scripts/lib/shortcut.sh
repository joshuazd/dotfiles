#!/usr/bin/env bash
#
# lib/shortcut.sh - Shortcut (project tracker) API helpers
#
# Usage:
#   source "${SCRIPT_DIR}/lib/shortcut.sh"

[[ -n "${__LIB_SHORTCUT_LOADED:-}" ]] && return
readonly __LIB_SHORTCUT_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

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
