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

# Marks the mnemonic letter in a menu label: "&Fetch and prune" binds `f`.
#
# The key lives inside the label rather than in a column of its own so it
# cannot drift from the text it abbreviates - a mnemonic that is not a letter
# of its own label is not a mnemonic. It also keeps the .menu format at two
# fields.
#
# The FIRST marker is the mnemonic and the only one stripped, so a label
# needing a literal ampersand can carry one after it. menus.bats rejects a
# second marker rather than leaving the reader to work out which one binds.
readonly MENU_KEY_MARKER='&'

# Keys for the two choices in a confirm menu.
readonly MENU_CONFIRM_KEY_YES='y'
readonly MENU_CONFIRM_KEY_NO='n'

# menu_confirm could not draw a native menu and did not ask anything. Distinct
# from a cancel, which is a real answer: the caller falls back to its own
# renderer rather than treating silence as "no".
readonly MENU_CONFIRM_UNDRAWN=2

# Columns to shift the menu from tmux's geometric centre, negative being
# leftward. Overridable with MENU_X_NUDGE.
#
# tmux centres the BOX, and a menu's text does not fill its box evenly: the
# key column down the right is mostly blank, so a geometrically centred menu
# still reads a little right. Two columns left looks centred.
readonly MENU_X_NUDGE_DEFAULT=-2

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
# The horizontal position is tmux's own `popup_centre_x` - the exact centre,
# computed by tmux from the menu's REAL drawn width - shifted by however far
# the pane's centre lies from the client's.
#
# That width is not observable from a script: tmux exposes it only to its own
# placement code. Estimating it was wrong twice, each time leaving the menu
# right of centre, because a drawn menu is several columns wider than its
# labels suggest. Taking tmux's number and translating it removes the estimate
# from the horizontal entirely, for every layout rather than only for a
# full-width pane.
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

  # tmux's own exact centre, shifted by however far the pane's centre is from
  # the client's. popup_centre_x already accounts for the real drawn width, so
  # nothing here has to estimate it - and for a full-width pane the offset is
  # zero, leaving tmux's centring untouched.
  #
  # MENU_X_NUDGE shifts it further, positive being rightward. Default -2, set
  # by eye: tmux centres the BOX, and a menu's text does not fill its box
  # evenly - the key column on the right is mostly blank - so a
  # geometrically centred menu still reads slightly right. Two columns left
  # made it look centred.
  local pane_offset=$(( (pane_left + pane_w / 2) - client_w / 2 ))
  local shift=$(( pane_offset + ${MENU_X_NUDGE:-${MENU_X_NUDGE_DEFAULT}} ))
  local x
  if [ "${shift}" -eq 0 ]; then
    x='#{popup_centre_x}'
  elif [ "${shift}" -gt 0 ]; then
    x="#{e|+:#{popup_centre_x},${shift}}"
  else
    x="#{e|-:#{popup_centre_x},$(( -shift ))}"
  fi

  local y=$((pane_top + (pane_h + menu_h) / 2))
  # The bottom cannot sit above the menu's own height, or it is drawn off the
  # top of the pane.
  [ "${y}" -lt "$((pane_top + menu_h))" ] && y="$((pane_top + menu_h))"

  printf '%s %s' "${x}" "${y}"
}

#######################################
# The mnemonic key a label asks for, or nothing when it carries no marker.
#
# Always LOWERCASE. tmux compares menu keys case-sensitively, and every label
# here is title case, so taking the marked character as written would bind
# Shift-F for "&Fetch and prune" - a two-handed chord for a menu whose whole
# point is one keystroke. Nothing shipped needs an uppercase key, and folding
# case also means a menu cannot grow a `d`/`D` pair that differ by Shift alone.
# Arguments:
#   The label, marker included
# Outputs:
#   A single lowercase character to stdout, or nothing
#######################################
menu_label_key() {
  local label="${1}"
  # A marker with nothing after it is a trailing ampersand, not a mnemonic.
  case "${label}" in
    *"${MENU_KEY_MARKER}"?*) ;;
    *) printf ''; return 0 ;;
  esac
  local after="${label#*"${MENU_KEY_MARKER}"}"
  printf '%s' "${after:0:1}" | tr '[:upper:]' '[:lower:]'
}

#######################################
# A label as it should be drawn: the marker removed, if it was one.
#
# A label whose only ampersand is trailing keeps it - it asked for no key, so
# there is nothing to strip and removing it would silently edit the text.
# Arguments:
#   The label, marker included
# Outputs:
#   The display text to stdout
#######################################
menu_label_text() {
  local label="${1}"
  if [ -z "$(menu_label_key "${label}")" ]; then
    printf '%s' "${label}"
    return 0
  fi
  printf '%s' "${label/${MENU_KEY_MARKER}/}"
}

#######################################
# Set MENU_POSITION_ARGS to the -x/-y flags that centre a menu on the pane.
#
# Returns through a global because bash 3.2 - still /bin/bash on macOS - has
# no way to return an array, and the two callers both need the flags as argv
# elements rather than as a string that would resplit.
#
# Empty when the pane cannot be measured: tmux's own default placement beats a
# number computed from nothing.
# Arguments:
#   Menu width, menu height
#######################################
menu_set_position() {
  MENU_POSITION_ARGS=()
  local xy
  xy="$(menu_centre_position "${1}" "${2}")"
  [ -n "${xy}" ] || return 0
  local x y
  read -r x y <<< "${xy}"
  MENU_POSITION_ARGS=(-x "${x}" -y "${y}")
}

#######################################
# Display a menu of TAB-delimited rows.
#
# Item names are NOT numbered: tmux draws the key at the end of the item line
# itself, so a numbered label shows the number twice - which is exactly how
# the first attempt at this looked wrong.
#
# A label carrying MENU_KEY_MARKER binds that letter; one without falls back
# to its position as a digit. Both, rather than one or the other, because the
# static .menu files have fixed labels worth memorising and the pickers'
# rows - worktrees, PRs, stories - have no stable text to be mnemonic about.
#
# A label of "-" becomes a separator: display-menu takes an empty name for
# that and expects the key and command to be omitted entirely, so a separator
# contributes ONE argv element where an item contributes three.
#
# A label BEGINNING with "-" is an information row: tmux draws it dim and
# refuses to select it, measured to ignore its key entirely. It still takes
# three argv slots, with the key and command empty.
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
  local row value label key text
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

    rows_drawn=$((rows_drawn + 1))
    if [ "${label:0:1}" = "-" ]; then
      args+=("${label}" "" "")
      [ "${#label}" -gt "${widest}" ] && widest="${#label}"
      continue
    fi

    n=$((n + 1))
    items=$((items + 1))
    text="$(menu_label_text "${label}")"
    key="$(menu_label_key "${label}")"
    if [ -z "${key}" ] && [ "${n}" -le 9 ]; then
      key="${n}"
    fi
    [ "${#text}" -gt "${widest}" ] && widest="${#text}"

    args+=("${text}" "${key}" \
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

  menu_set_position "${menu_w}" "${menu_h}"

  local shown_title="#[align=centre] ${title} "
  if [ -n "${MENU_DEBUG_POS:-}" ]; then
    shown_title="xy=${MENU_POSITION_ARGS[*]:-unmeasured} mw=${menu_w} mh=${menu_h}"
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
    ${MENU_POSITION_ARGS+"${MENU_POSITION_ARGS[@]}"} \
    -- "${args[@]}"
}

#######################################
# Offer a destructive action as a native tmux confirm menu.
#
# The chosen item RUNS the action. No answer travels back, which is the whole
# point: `tmux display-menu` cannot be relied on to block until the menu is
# answered. Measured on this machine, from a menu item's `run-shell -b`, it
# returned 0 one second after opening while the menu was still on screen and
# unanswered - so a caller that read an answer variable afterwards always read
# the seeded default, reported "cancelled", and exited. The keypress then
# landed on a menu nobody was listening to, and the whole thing looked like a
# confirm that did nothing. An earlier harness DID see it block, which is
# exactly why this must not be built on that behaviour.
#
# This is also how tmux writes its own confirmations:
#   display-menu -T "Kill pane?" Yes y { kill-pane } No n { }
#
# Cancel is listed first, so it is the resting cursor position and what an
# accidental Enter picks; it runs nothing. Escape and `q` dismiss the menu
# without running any item, so they cancel too, for free.
#
# It must NOT be called from inside a display-popup: a menu asked for while a
# popup holds the client's overlay returns 0 without ever drawing, so the user
# is never asked. Callers gate on having no tty, which is what tells them no
# popup is in the way.
# Arguments:
#   Menu title
#   Label for the confirming item
#   Shell command the confirming item runs - already shell-quoted
#   Remaining arguments become dim information rows above the choices
# Returns:
#   0 when the menu was displayed, MENU_CONFIRM_UNDRAWN when it could not be
#######################################
menu_confirm() {
  local title="${1}"
  local confirm_label="${2}"
  local on_confirm="${3}"
  shift 3

  [ -n "${TMUX:-}" ] || return "${MENU_CONFIRM_UNDRAWN}"

  local -a args=()
  local rows=2
  local widest="${#confirm_label}"
  [ "${#title}" -gt "${widest}" ] && widest="${#title}"

  local info
  for info in ${1+"${@}"}; do
    [ -n "${info}" ] || continue
    args+=("-${info}" "" "")
    rows=$((rows + 1))
    [ "${#info}" -gt "${widest}" ] && widest="${#info}"
  done
  if [ "${#args[@]}" -gt 0 ]; then
    args+=("")
    rows=$((rows + 1))
  fi

  menu_fits "${rows}" || return "${MENU_CONFIRM_UNDRAWN}"

  # An empty command is how tmux's own confirm menus spell "do nothing".
  args+=("Cancel" "${MENU_CONFIRM_KEY_NO}" "")
  args+=("${confirm_label}" "${MENU_CONFIRM_KEY_YES}" \
    "run-shell -b $(menu_tmux_quote "${on_confirm}")")

  menu_set_position "$((widest + MENU_KEY_COLS + MENU_BORDER_COLS))" \
    "$((rows + MENU_BORDER_ROWS))"

  tmux display-menu \
    -T "#[align=centre] ${title} " \
    -b rounded \
    ${MENU_POSITION_ARGS+"${MENU_POSITION_ARGS[@]}"} \
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
