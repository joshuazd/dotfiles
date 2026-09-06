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
