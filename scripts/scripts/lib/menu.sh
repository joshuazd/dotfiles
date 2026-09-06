#!/usr/bin/env bash
#
# lib/menu.sh - native tmux display-menu rendering
#
# Owns every `display-menu` invocation's argv in this package, the way
# lib/picker.sh owns fzf's: item construction, key assignment, quoting, and
# the fit test that decides which backend a caller gets.
#
# Rows are TAB-delimited "value<TAB>label", the same shape lib/picker.sh
# consumes, so a caller can hand the same rows to either backend.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/menu.sh"
#   printf 'run-me\tAlpha\n' | menu_show "Title" "$(printf '%q' "${0}") --act go"

[[ -n "${__LIB_MENU_LOADED:-}" ]] && return
readonly __LIB_MENU_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/picker.sh"

# Rows a menu costs on top of its items: two for the border, one for the
# title, and one of slack so a menu never lands exactly on the limit.
#
# Deliberately generous. `man tmux`: "If the menu is too large to fit on the
# terminal, it is not displayed" - no scrolling, no truncation, no error.
# Overestimating falls back to fzf slightly early; underestimating shows the
# user nothing at all and looks like a broken keybinding.
readonly MENU_CHROME_ROWS=4

#######################################
# Height of the attached client, in rows.
# Outputs:
#   The height to stdout, or nothing when it cannot be measured
#######################################
menu_client_height() {
  local height
  height="$(tmux display-message -p '#{client_height}' 2>/dev/null || true)"
  case "${height}" in
    ''|*[!0-9]*) printf '' ;;
    *)           printf '%s' "${height}" ;;
  esac
}

#######################################
# Whether a menu of this many items will actually be displayed.
#
# An unmeasurable height counts as "does not fit": the fzf fallback always
# works, a blank menu never does.
# Arguments:
#   Item count
# Returns:
#   0 if it fits, 1 otherwise
#######################################
menu_fits() {
  local count="${1}"
  local height
  height="$(menu_client_height)"
  [ -n "${height}" ] || return 1
  [ "$((count + MENU_CHROME_ROWS))" -le "${height}" ]
}
