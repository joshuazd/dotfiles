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

# Chrome around a menu's items, for sizing it: a border column each side plus
# a padding column each side, and a border row top and bottom. The key column
# is the widest key plus the gap tmux leaves before it.
#
# MENU_KEY_COLS is only used for the horizontal ESTIMATE, which in turn is
# only used for a pane that does not span the client's full width - a
# full-width pane gets tmux's own `C`, which centres on the real drawn width.
# The estimate is known to run several columns narrow than what tmux draws;
# raising it moves such a menu left.
readonly MENU_BORDER_COLS=4
readonly MENU_BORDER_ROWS=2
readonly MENU_KEY_COLS=6

# Centring is computed HERE, in the shell, and passed to -x/-y as plain
# numbers.
#
# The obvious approach - a format over tmux's own popup_width, popup_height,
# popup_pane_left and popup_pane_top - does not work: those variables expand
# to EMPTY in -x/-y, so the arithmetic silently treated them as zero and put
# the menu's LEFT EDGE at the pane's centre. Measured with MENU_DEBUG_POS,
# which reported "x=76 y=31 mw= mh= pw=152 ph=62 pl= pt=" - every popup_*
# field blank, and x exactly pane_width/2.
#
# So the menu's size has to be estimated from the rows, which is possible
# because this function has them. The estimate can be off by a column if a
# label contains wide characters; being a column out is a cosmetic miss,
# whereas relying on the empty variables was half a menu out.

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

#######################################
# Single-quote a string for tmux's command parser.
#
# The command handed to display-menu is parsed by TMUX first and by the shell
# second, so a value crosses two parsers. This covers the tmux one; the caller
# uses printf '%q' for the shell. Embedded single quotes are closed, escaped
# and reopened, which is the same idiom a POSIX shell needs.
# Arguments:
#   The string to quote
# Outputs:
#   The quoted string to stdout
#######################################
menu_tmux_quote() {
  local s="${1}"
  printf "'%s'" "$(printf '%s' "${s}" | sed "s/'/'\\\\''/g")"
}

#######################################
# Geometry of the focused pane: left, top, width and height.
#
# One query, so the four numbers describe the same pane even if focus moves.
# Outputs:
#   "left top width height" to stdout, or nothing when unmeasurable
#######################################
menu_pane_geometry() {
  local geom
  geom="$(tmux display-message -p \
    '#{pane_left} #{pane_top} #{pane_width} #{pane_height} #{client_width}' \
    2>/dev/null || true)"
  case "${geom}" in
    ''|*[!0-9\ ]*) printf '' ;;
    *)             printf '%s' "${geom}" ;;
  esac
}

#######################################
# Position that centres a menu on the focused pane.
#
# The horizontal half prefers tmux's own `C`, which centres using the menu's
# REAL drawn width. That width is not observable from a script - tmux exposes
# it only to its own placement code - so any width computed here is an
# estimate, and estimating it was repeatedly wrong: the menu kept sitting
# right of centre because the drawn menu is several columns wider than the
# labels suggest.
#
# `C` is the centre of the CLIENT, so it is only equal to the centre of the
# pane when the pane spans the client's full width. That covers the common
# case of a vertical stack of panes. A horizontally split pane falls back to
# the estimate, which is approximate but bounded, and better than centring on
# the wrong pane entirely.
#
# The vertical half is always computed, since a pane's rows rarely match the
# client's. -y names the menu's BOTTOM row, so the height is ADDED. Measured:
# with -y 91 and an 8-row menu in a pane spanning rows 64 to 125, the menu
# drew at 84 to 91, about seven rows above the pane's centre. Top-semantics
# would have been centred, so it cannot be that.
# Arguments:
#   Menu width, menu height
# Outputs:
#   "x y" to stdout, or nothing when the pane cannot be measured
#######################################
menu_centre_position() {
  local menu_w="${1}"
  local menu_h="${2}"

  local geom
  geom="$(menu_pane_geometry)"
  [ -n "${geom}" ] || { printf ''; return 0; }

  local pane_left pane_top pane_w pane_h client_w
  read -r pane_left pane_top pane_w pane_h client_w <<< "${geom}"

  local x
  if [ "${pane_left}" -eq 0 ] && [ "${pane_w}" -eq "${client_w}" ]; then
    x="C"
  else
    x=$((pane_left + (pane_w - menu_w) / 2))
    [ "${x}" -lt "${pane_left}" ] && x="${pane_left}"
  fi

  local y=$((pane_top + (pane_h + menu_h) / 2))
  # The bottom cannot sit above the menu's own height, or it is drawn off the
  # top of the pane.
  [ "${y}" -lt "$((pane_top + menu_h))" ] && y="$((pane_top + menu_h))"

  printf '%s %s' "${x}" "${y}"
}

#######################################
# Display a menu of TAB-delimited rows.
#
# Item names are NOT numbered: tmux draws the key at the end of the item line
# itself, so a numbered label shows the number twice - which is exactly how
# the first attempt at this looked wrong.
#
# A label of "-" becomes a separator: display-menu takes an empty name for
# that and expects the key and command to be omitted entirely, so a separator
# contributes ONE argv element where an item contributes three.
# Arguments:
#   Menu title
#   Act prefix - a shell-quoted command that takes one value argument
# Inputs:
#   "value<TAB>label" rows on stdin
# Returns:
#   0 on success, PICKER_EMPTY when there were no rows
#######################################
menu_show() {
  local title="${1}"
  local act_prefix="${2}"

  local -a args=()
  local row value label key
  local n=0
  local items=0
  local rows_drawn=0
  local widest=0

  while IFS= read -r row; do
    [ -n "${row}" ] || continue
    value="${row%%$'\t'*}"
    label="${row#*$'\t'}"

    if [ "${label}" = "-" ]; then
      args+=("")
      rows_drawn=$((rows_drawn + 1))
      continue
    fi

    n=$((n + 1))
    items=$((items + 1))
    rows_drawn=$((rows_drawn + 1))
    [ "${#label}" -gt "${widest}" ] && widest="${#label}"
    if [ "${n}" -le 9 ]; then
      key="${n}"
    else
      key=""
    fi

    args+=("${label}" "${key}" \
      "run-shell -b $(menu_tmux_quote "${act_prefix} $(printf '%q' "${value}")")")
  done

  if [ "${items}" -eq 0 ]; then
    return "${PICKER_EMPTY}"
  fi

  # The title widens the menu too, so it counts toward the estimate.
  local menu_w="$((widest + MENU_KEY_COLS + MENU_BORDER_COLS))"
  local title_w="$(( ${#title} + MENU_BORDER_COLS ))"
  [ "${title_w}" -gt "${menu_w}" ] && menu_w="${title_w}"
  local menu_h="$((rows_drawn + MENU_BORDER_ROWS))"

  local -a pos=()
  local xy
  xy="$(menu_centre_position "${menu_w}" "${menu_h}")"
  if [ -n "${xy}" ]; then
    local x y
    read -r x y <<< "${xy}"
    pos=(-x "${x}" -y "${y}")
  fi

  local shown_title="#[align=centre] ${title} "
  if [ -n "${MENU_DEBUG_POS:-}" ]; then
    shown_title="xy=${xy:-unmeasured} mw=${menu_w} mh=${menu_h}"
    shown_title="${shown_title} pane=$(menu_pane_geometry)"
  fi

  # -- terminates the options: a label may begin with a hyphen, which is both
  # display-menu's "disabled item" marker and the shape of its own flags.
  #
  # No -x/-y at all when the pane could not be measured: tmux's own default
  # placement is a better answer than a number computed from nothing.
  tmux display-menu \
    -T "${shown_title}" \
    -b rounded \
    ${pos+"${pos[@]}"} \
    -- "${args[@]}"
}

#######################################
# Choose a value from rows and act on it, using whichever backend can show
# them.
#
# A native menu when the rows fit, fzf when they do not. Both paths end at the
# same act prefix, which is the whole reason the fallback can be trusted: the
# backends differ in how a value is chosen and in nothing else.
# Arguments:
#   Menu title
#   Act prefix - a shell-quoted command taking one value argument
#   Popup command - how to re-run the caller inside a popup when the fzf path
#     is needed and there is no terminal to draw it on. Empty to disable.
#   Remaining arguments are passed through to pick_one
# Inputs:
#   "value<TAB>label" rows on stdin
# Returns:
#   0 on success, PICKER_EMPTY on no rows, PICKER_QUIET_EXIT when the user
#   backed out of the fzf path
#######################################
menu_or_pick() {
  local title="${1}"
  local act_prefix="${2}"
  local popup_cmd="${3}"
  shift 3

  # Read the caller's empty-message so the menu path can report an empty list
  # in the same words pick_one would. It stays in the forwarded arguments.
  local empty_message=""
  local -a forwarded=()
  local arg
  local want_message=""
  for arg in ${1+"${@}"}; do
    forwarded+=("${arg}")
    if [ -n "${want_message}" ]; then
      empty_message="${arg}"
      want_message=""
    elif [ "${arg}" = "--empty-message" ]; then
      want_message=1
    fi
  done

  local rows
  rows="$(cat)"
  if [ -z "${rows}" ]; then
    warn "${empty_message:-nothing to pick from}"
    return "${PICKER_EMPTY}"
  fi

  local count
  count="$(printf '%s\n' "${rows}" | grep -c . || true)"
  [ -n "${count}" ] || count=0

  if menu_fits "${count}"; then
    printf '%s\n' "${rows}" | menu_show "${title}" "${act_prefix}"
    return "${?}"
  fi

  # fzf needs a terminal. Invoked from a menu item the caller is running under
  # `run-shell`, which has none, so it re-enters inside a popup - where the fit
  # test comes out the same and this branch is reached again, with a terminal.
  #
  # The test is on STDOUT, not stdin: stdin here is the pipe carrying the rows
  # and is never a terminal, so testing it would re-enter a popup every time,
  # including from inside one.
  #
  # MENU_ASSUME_TTY skips the re-entry, which is how the tests exercise the
  # fzf path without a terminal - the same kind of seam as FZF_MENU_DIR and
  # SCRIPTS_PKG_DIR elsewhere in this package.
  if [ -z "${MENU_ASSUME_TTY:-}" ] && [ ! -t 1 ] && [ -n "${popup_cmd}" ]; then
    tmux display-popup -E -w 80% -h 60% "${popup_cmd}"
    return "${?}"
  fi

  local selection status=0
  selection="$(printf '%s\n' "${rows}" \
    | pick_one ${forwarded+"${forwarded[@]}"})" || status="${?}"

  if [ "${status}" -eq "${PICKER_NO_SELECTION}" ]; then
    return "${PICKER_QUIET_EXIT}"
  fi
  if [ "${status}" -ne 0 ]; then
    return "${status}"
  fi

  local value="${selection%%$'\t'*}"
  # act_prefix is built by the caller from a %q-escaped script path plus fixed
  # flags, and the value is escaped here, so both halves are safe to evaluate.
  eval "${act_prefix} $(printf '%q' "${value}")"
}
