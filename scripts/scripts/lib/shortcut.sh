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
# Fetch story title and git branch from Shortcut.
#
# `%t` gives the plain title. We avoid `%gb`, which forces a
# `<mention-name>/sc-<id>/<type>-<slug>` shape; we want the
# workspace-configured branch (`formatted_vcs_branch_name`) instead.
#
# That field isn't exposed as a `%`-placeholder, so we extract it from
# `%j` (the full JSON) with grep — keeps us off jq, which has historically
# choked on control chars elsewhere in the JSON. The field is
# server-generated from a slug, so a plain regex is safe.
#
# Arguments:
#   story_id — numeric story ID
# Outputs:
#   Writes "<title>\t<branch>" (single line, tab-delimited) to stdout
#######################################
fetch_story_summary() {
  local story_id="${1}"
  local output title branch_name

  if ! output="$(short story "${story_id}" --format $'%t\n%j' -q 2>/dev/null)"; then
    error "Failed to fetch story ${story_id} from Shortcut"
    return 1
  fi

  title="${output%%$'\n'*}"
  branch_name="$(printf '%s' "${output}" \
    | grep -E '^  "formatted_vcs_branch_name": "' \
    | head -1 \
    | sed -E 's/^  "formatted_vcs_branch_name": "(.*)",?$/\1/')"

  if [ -z "${branch_name}" ]; then
    error "No formatted_vcs_branch_name found for story ${story_id}"
    return 1
  fi

  printf "%s\t%s" "${title}" "${branch_name}"
}
