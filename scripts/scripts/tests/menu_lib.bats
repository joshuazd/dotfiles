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
@test "options are terminated so a label may start with a hyphen" {
  printf 'v1\t-Not selectable\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" == *"--"* ]]
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
# The position is computed in the shell and passed as plain numbers. A tmux
# format cannot do it: popup_width, popup_height, popup_pane_left and
# popup_pane_top all expand to EMPTY in -x/-y, which put the menu's left edge
# at the pane's centre.
@test "the position is passed as numbers, not as a format" {
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" != *"popup_width"* ]]
  [[ "${output}" != *"popup_pane_left"* ]]
  [[ "${output}" != *"#{e|"* ]]
}

# A 1-item menu in a 120x40 pane: menu_h = 1 + 2 = 3, so y = (40-3)/2 = 18.
# The label is 3 wide, so menu_w = 3 + 4 + 4 = 11 and x = (120-11)/2 = 54.
@test "the menu is centred on the pane" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" "54"
  printf '%s\n' "${output}" | assert_arg_after "-y" "18"
}

# The centre is the PANE's, so a pane offset within the window shifts it.
@test "a pane offset within the window shifts the menu" {
  export TMUX_STUB_PANE_GEOMETRY="60 20 60 20"
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" "84"
  printf '%s\n' "${output}" | assert_arg_after "-y" "28"
}

# A long label widens the menu, which moves its left edge left.
@test "a wider menu is still centred" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 120 40"
  printf 'v1\tA label that is rather long indeed\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  # 34 + 4 + 4 = 42, so x = (120-42)/2 = 39.
  printf '%s\n' "${output}" | assert_arg_after "-x" "39"
}

# A menu wider than its pane would otherwise get a negative column, which
# tmux places off-screen.
@test "the position never goes outside the pane" {
  export TMUX_STUB_PANE_GEOMETRY="0 0 10 4"
  printf 'v1\tA label far wider than this pane\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "-x" "0"
  printf '%s\n' "${output}" | assert_arg_after "-y" "0"
}

# Better tmux's own placement than a number derived from nothing.
@test "an unmeasurable pane means no position at all" {
  export TMUX_STUB_PANE_GEOMETRY=""
  printf 'v1\tOne\n' | menu_show "T" "act"
  run tmux_call_args display-menu
  [[ "${output}" != *"-x"* ]]
  [[ "${output}" != *"-y"* ]]
}
