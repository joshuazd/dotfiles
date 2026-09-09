#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  source "${BATS_TEST_DIRNAME}/../lib/menu.sh"
}

@test "a short list fits a tall client" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run menu_fits 6
  [ "${status}" -eq 0 ]
}

@test "a list taller than the client does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits 60
  [ "${status}" -ne 0 ]
}

# The boundary is the whole point: one row short blanks the menu rather than
# shrinking it, so the comparison has to include the chrome.
@test "the chrome counts against the height" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits $((10 - MENU_CHROME_ROWS))
  [ "${status}" -eq 0 ]
  run menu_fits $((10 - MENU_CHROME_ROWS + 1))
  [ "${status}" -ne 0 ]
}

# An unmeasurable height must not be treated as unlimited.
@test "an unmeasurable client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=""
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "a non-numeric client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT="not-a-number"
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "menu_client_height reports what tmux says" {
  export TMUX_STUB_CLIENT_HEIGHT=33
  run menu_client_height
  [ "${output}" = "33" ]
}

@test "the label is the item name, unnumbered" {
  printf 'v1\tFetch\nv2\tStatus\n' | menu_show "Git" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"Fetch"* ]]
  [[ "${output}" != *"1 Fetch"* ]]
}

# tmux renders the key at the end of the item line, so the key belongs in the
# key argument and not in the label.
@test "the first nine items get digit keys" {
  printf 'v1\tOne\nv2\tTwo\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "One" "1"
  printf '%s\n' "${output}" | assert_arg_after "Two" "2"
}

@test "items past the ninth get an empty key" {
  local i
  for i in $(seq 1 11); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Item9" "9"
  printf '%s\n' "${output}" | assert_arg_after "Item10" ""
}

@test "each item runs the act prefix with its value" {
  printf 'the-value\tOne\n' | menu_show "T" "wt-pick --act switch"
  run tmux_call_args display-menu
  [[ "${output}" == *"run-shell"* ]]
  [[ "${output}" == *"wt-pick --act switch"* ]]
  [[ "${output}" == *"the-value"* ]]
}

# A worktree path with a space in it must act on that path, not on its first
# word, so the value has to reach the command as ONE shell word. Asserting on
# the unescaped text would be asserting on the bug: correct output is escaped.
@test "a value containing spaces reaches the command as one word" {
  printf '/tmp/two words\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *'two\ words'* ]]
}

# The property the escaping exists for, checked by actually running it.
@test "the built command passes the value as a single argument" {
  setup_cmd_stubs
  stub_cmd recorder
  printf '/tmp/two words\tOne\n' | menu_show "T" "recorder"
  run tmux_call_args display-menu
  local cmd
  cmd="$(printf '%s\n' "${output}" | grep '^run-shell')"
  cmd="${cmd#run-shell -b }"
  eval "eval ${cmd}"
  run cmd_call_args recorder
  [ "${lines[1]}" = "/tmp/two words" ]
  [ -z "${lines[2]:-}" ]
}

@test "a value containing a single quote survives" {
  printf "/tmp/it's\tOne\n" | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"it"* ]]
}

@test "a dash label becomes a separator with no key or command" {
  printf 'v1\tOne\nignored\t-\nv2\tTwo\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"One"* ]]
  [[ "${output}" == *"Two"* ]]
}

# display-menu treats a leading hyphen as "disabled item", and its own options
# start with one too, so argv needs a -- terminator.
# A hyphen is both display-menu's disabled-item marker and the shape of its
# own flags, so without -- tmux reads the label as an option and the menu never
# draws. A selectable row rides along because a menu of nothing but information
# has nothing to pick and returns empty before it gets this far.
@test "options are terminated so a label may start with a hyphen" {
  printf 'v1\t-Not selectable\nv2\tPickable\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"--"* ]]
}

@test "a label starting with a hyphen becomes an information row" {
  printf 'v1\t-3 uncommitted files\nv2\tPickable\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"-3 uncommitted files"* ]]
  # tmux ignores a disabled row's key and command, and giving it a real one
  # would spend a digit the pickable rows should have had.
  printf '%s\n' "${output}" | refute_arg_after "-3 uncommitted files" "1"
}

@test "an information row does not consume a digit" {
  printf 'v1\t-context\nv2\tFirst\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "First" "1"
}

@test "a menu of only information rows has nothing to pick" {
  run bash -c 'source '"${BATS_TEST_DIRNAME}"'/../lib/menu.sh
    printf "v1\t-just context\n" | menu_show "T" "act"'
  [ "${status}" -eq "${PICKER_EMPTY}" ]
}

@test "a marked label binds its letter instead of a digit" {
  printf 'v1\t&Fetch and prune\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Fetch and prune" "f"
}

@test "the marker is stripped from what tmux draws" {
  printf 'v1\tRes&pawn this pane\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"Respawn this pane"* ]]
  [[ "${output}" != *"Res&pawn"* ]]
}

@test "a marker in the middle of a label binds that letter" {
  printf 'v1\tRes&pawn this pane\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Respawn this pane" "p"
}

# The pickers' rows are worktree paths and PR titles: no stable text to be
# mnemonic about, so they keep the positional digits.
@test "an unmarked label still gets its position as a key" {
  printf 'v1\tOne\nv2\tTwo\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "One" "1"
  printf '%s\n' "${output}" | assert_arg_after "Two" "2"
}

@test "a trailing ampersand is not a mnemonic" {
  printf 'v1\tCommit &\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Commit &" "1"
}

@test "only the first marker is stripped" {
  run menu_label_text 'A&B&C'
  [ "${output}" = "AB&C" ]
}

@test "a label with no marker asks for no key" {
  run menu_label_key 'Plain label'
  [ -z "${output}" ]
}

@test "the title goes in -T, not into an item" {
  printf 'v1\tOne\n' | menu_show "Git actions" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-T" "#[align=centre] Git actions "
}

@test "the menu is given a border style" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-b" "rounded"
}

@test "no rows means no menu" {
  run bash -c "source '${BATS_TEST_DIRNAME}/../lib/menu.sh'; printf '' | menu_show T act"
  refute_tmux_subcommand display-menu
}

@test "a fitting list renders a menu and no fzf" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=40
  printf 'v1\tOne\n' | menu_or_pick "T" "true" "" --empty-message "none"
  assert_tmux_subcommand display-menu
  refute_fzf_called
}

@test "a list too tall for the client uses fzf and no menu" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'v3\tThree'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "true" "" --empty-message "none"
  refute_tmux_subcommand display-menu
  [ -s "${FZF_STUB_LOG}" ]
}

# The point of the design: both backends reach the same act half.
@test "the fzf path invokes the act prefix with the chosen value" {
  setup_fzf_stub
  setup_cmd_stubs
  stub_cmd acted
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'chosen-value\tThree'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "acted" "" --empty-message "none"
  run cmd_call_args acted
  [ "${lines[1]}" = "chosen-value" ]
}

@test "escaping the fzf path acts on nothing and closes quietly" {
  setup_fzf_stub
  setup_cmd_stubs
  stub_cmd acted
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_ABORT=1
  local i status=0
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "acted" "" --empty-message "none" || status="${?}"
  [ "${status}" -eq "${PICKER_QUIET_EXIT}" ]
  refute_cmd_called acted
}

@test "an empty list reports the caller's message and renders nothing" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=40
  run bash -c "source '${BATS_TEST_DIRNAME}/../lib/menu.sh'; printf '' | menu_or_pick T true '' --empty-message 'No open PRs.'"
  [ "${status}" -eq 3 ]
  [[ "${output}" == *"No open PRs."* ]]
  refute_tmux_subcommand display-menu
}

@test "pick_one options are forwarded on the fzf path" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=6
  export FZF_STUB_SELECTION=$'v1\tOne'
  local i
  for i in $(seq 1 20); do printf 'v%s\tItem%s\n' "${i}" "${i}"; done \
    | menu_or_pick "T" "true" "" --prompt "Pick this> " --empty-message "none"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "Pick this> "
}

# The menu path must reach the same act half, via the command it builds.
@test "the menu path builds items calling the act prefix" {
  setup_fzf_stub
  export TMUX_STUB_CLIENT_HEIGHT=40
  printf 'the-value\tOne\n' | menu_or_pick "T" "acted" "" --empty-message "none"
  run tmux_call_args display-menu
  [[ "${output}" == *"acted"* ]]
  [[ "${output}" == *"the-value"* ]]
}

# -x C -y C centres on the terminal, which on a split window is not where the
# user is looking. The pane variables are only expanded while tmux positions
# the menu, so all a unit test can check is that the formats were passed.
# The menu's own drawn size must never reach the position: popup_width and
# popup_height do not expand in -x/-y, and estimating them left the menu right
# of centre twice. The horizontal comes from tmux's popup_centre_x instead,
# and the vertical is a plain row number.
@test "the menu's own size does not reach the position" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" != *"popup_width"* ]]
  [[ "${output}" != *"popup_height"* ]]
  [[ "${output}" != *"popup_pane_left"* ]]
}

# The horizontal position is tmux's own exact centre. A full-width pane needs
# no shift at all, so it is passed through untouched - the menu's drawn width
# is not observable from a script, and estimating it left the menu right of
# centre twice.
#
# Vertically: menu_h = 1 + 2 = 3 and -y is the BOTTOM row, so y = (40+3)/2 = 21.
@test "a full-width pane uses tmux's centre plus only the nudge" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40 120"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  # No pane offset, so the whole shift is MENU_X_NUDGE_DEFAULT of -2.
  printf '%s\n' "${output}" | assert_arg_after "-x" '#{e|-:#{popup_centre_x},2}'
  printf '%s\n' "${output}" | assert_arg_after "-y" "21"
}

# A pane left of the client's centre shifts tmux's centre left by the same
# distance, which needs no knowledge of the menu's width.
@test "a left-hand pane shifts tmux's centre left" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 60 40 120"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  # pane centre 30, client centre 60, so 30 left, plus the -2 nudge.
  printf '%s\n' "${output}" | assert_arg_after "-x" '#{e|-:#{popup_centre_x},32}'
}

@test "a right-hand pane shifts tmux's centre right" {
  export TMUX_STUB_PANE_GEOMETRY="60 0 60 40 120"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  # pane centre 90, client centre 60, so 30 right, less the -2 nudge.
  printf '%s\n' "${output}" | assert_arg_after "-x" '#{e|+:#{popup_centre_x},28}'
}

# The nudge and the pane offset can cancel exactly, which must leave tmux's
# own number untouched rather than a +0 expression.
@test "a shift of zero passes tmux's centre through untouched" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40 120"
  export MENU_X_NUDGE=0
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" '#{popup_centre_x}'
}

# The knob exists because "centred" is partly perception once the box is wider
# than its text.
@test "MENU_X_NUDGE shifts the result" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40 120"
  export MENU_X_NUDGE=-3
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" '#{e|-:#{popup_centre_x},3}'
}

# The vertical centre is the PANE's, so a pane offset down the window moves it.
@test "a pane offset down the window shifts the menu down" {
  export TMUX_STUB_PANE_GEOMETRY="60 20 60 20 120"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  # y = 20 + (20 + 3)/2 = 31
  printf '%s\n' "${output}" | assert_arg_after "-y" "31"
}

# The label width no longer reaches the horizontal position at all: tmux
# computes the centre from the width it actually drew. This is the property
# that two rounds of estimating the width failed to achieve.
@test "the label width does not move the menu horizontally" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40 120"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  local narrow="${output}"
  setup_tmux_stub
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40 120"
  printf 'v1\tA label that is rather long indeed\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [ "$(printf '%s\n' "${narrow}" | grep -c 'popup_centre_x')" -eq \
    "$(printf '%s\n' "${output}" | grep -c 'popup_centre_x')" ]
}

# -y is the bottom row, so it cannot rise above the menu's own height without
# the menu being drawn off the top of the pane.
@test "the vertical position never goes above the pane" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 10 4 10"
  printf 'v1\tA label far wider than this pane\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-y" "3"
}

# Better tmux's own placement than a number derived from nothing.
@test "an unmeasurable pane means no position at all" {
  export TMUX_STUB_PANE_GEOMETRY=""
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" != *"-x"* ]]
  [[ "${output}" != *"-y"* ]]
}

# --- menu_confirm ---------------------------------------------------------
#
# The confirming item RUNS the action; nothing is read back. `tmux
# display-menu` was measured returning 0 one second after opening, with the
# menu still on screen and unanswered, so every test here asserts on the argv
# handed to display-menu rather than on an answer that may never arrive.

@test "a displayed menu reports success" {
  run menu_confirm "Remove?" "Remove it" "true"
  [ "${status}" -eq 0 ]
}

@test "outside tmux nothing is asked" {
  unset TMUX
  run menu_confirm "Remove?" "Remove it" "true"
  [ "${status}" -eq "${MENU_CONFIRM_UNDRAWN}" ]
  refute_tmux_subcommand display-menu
}

# A menu too tall for the client is not displayed at all - no scroll, no
# error - so it must report that nothing was asked. A caller that took silence
# for a cancel would drop the action on the floor; one that took it for a
# confirm would destroy something nobody agreed to.
@test "a client too short for the menu asks nothing" {
  export TMUX_STUB_CLIENT_HEIGHT=1
  run menu_confirm "Remove?" "Remove it" "true"
  [ "${status}" -eq "${MENU_CONFIRM_UNDRAWN}" ]
  refute_tmux_subcommand display-menu
}

@test "undrawn is distinct from success" {
  [ "${MENU_CONFIRM_UNDRAWN}" -ne 0 ]
}

@test "the confirming item runs the action in the background" {
  menu_confirm "Remove?" "Remove it" "do-the-thing --now"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" \
    | assert_arg_after "Remove it" "${MENU_CONFIRM_KEY_YES}"
  [[ "${output}" == *"run-shell -b"* ]]
  [[ "${output}" == *"do-the-thing --now"* ]]
}

# Escape and q dismiss without running any item, so cancelling needs no
# command of its own - and must not be given one.
@test "cancel runs nothing at all" {
  menu_confirm "Remove?" "Remove it" "do-the-thing"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" \
    | assert_arg_after "Cancel" "${MENU_CONFIRM_KEY_NO}"
  # The argument after the key is the command, and for Cancel it is empty.
  local after_key=0 line
  while IFS= read -r line; do
    if [ "${after_key}" -eq 1 ]; then
      [ -z "${line}" ]
      return 0
    fi
    [ "${line}" = "${MENU_CONFIRM_KEY_NO}" ] && after_key=1
  done <<< "${output}"
  return 1
}

# Cancel is the first choice, so it is the resting cursor position and what an
# accidental Enter picks. A destructive default is the bug the gate exists for.
@test "cancel comes before the confirming choice" {
  menu_confirm "Remove?" "Remove it" "true"
  run tmux_call_args display-menu
  local before_cancel="${output%%Cancel*}"
  local before_confirm="${output%%Remove it*}"
  [ "${#before_cancel}" -lt "${#before_confirm}" ]
}

# An action with a space in a path must reach the shell as one word, and the
# command crosses tmux's parser before the shell's. Asserting on the plain
# text would be asserting on the bug.
@test "the action survives tmux's own parser" {
  menu_confirm "Remove?" "Remove it" "cleanup '/tmp/two words'"
  run tmux_call_args display-menu
  [[ "${output}" == *"two words"* ]]
}

@test "information rows are disabled and precede the choices" {
  menu_confirm "Remove?" "Remove it" "true" "~/code/thing" "on main"
  run tmux_call_args display-menu
  [[ "${output}" == *"-~/code/thing"* ]]
  [[ "${output}" == *"-on main"* ]]
  local before_info="${output%%-on main*}"
  local before_cancel="${output%%Cancel*}"
  [ "${#before_info}" -lt "${#before_cancel}" ]
}

# An empty summary would otherwise draw a blank dim row.
@test "an empty information row is dropped" {
  menu_confirm "Remove?" "Remove it" "true" "" "on main"
  run tmux_call_args display-menu
  refute_arg_after "-" ""
  [[ "${output}" == *"-on main"* ]]
}

@test "the confirm menu is centred like any other" {
  menu_confirm "Remove?" "Remove it" "true"
  run tmux_call_args display-menu
  [[ "${output}" == *"-x"* ]]
  [[ "${output}" == *"-y"* ]]
}

@test "the confirm menu carries its title" {
  menu_confirm "Remove 'thing'?" "Remove it" "true"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-T" "#[align=centre] Remove 'thing'? "
}

# No answer travels back, so nothing may be left in the server environment.
@test "no answer variable is used at all" {
  menu_confirm "Remove?" "Remove it" "true"
  refute_tmux_subcommand set-environment
  refute_tmux_subcommand show-environment
}
