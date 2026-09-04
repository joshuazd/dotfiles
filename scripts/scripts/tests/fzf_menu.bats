#!/usr/bin/env bats

load helper

# Fixtures deliberately use `echo`, never real git commands. Task 3 makes a
# bare command actually execute, and a fixture that shells out to git would
# turn this suite into a slow, side-effecting one the moment that lands.

setup() {
  setup_fzf_stub
  export FZF_MENU_DIR="${BATS_TEST_TMPDIR}/menus"
  mkdir -p "${FZF_MENU_DIR}"
  MENU="${FZF_MENU_DIR}/demo.menu"
  printf '# Demo actions\nFetch\techo fetch-ran\nStatus\techo hidden-command-ran\n' > "${MENU}"
  FZF_MENU="${BATS_TEST_DIRNAME}/../fzf-menu"
}

@test "the header comes from the first comment line" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "Demo actions"
}

@test "a menu without a header comment falls back to the menu name" {
  printf 'Fetch\techo fetch-ran\n' > "${FZF_MENU_DIR}/bare.menu"
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" bare
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "bare"
}

@test "labels are the display column and commands are hidden" {
  export FZF_STUB_SELECTION=$'echo hidden-command-ran\tStatus'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  # The marker appears whether main prints the command (this task) or runs it
  # (Task 3), so this assertion survives the dispatch change.
  [[ "${output}" == *"hidden-command-ran"* ]]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "a missing menu exits 2 and lists what is available" {
  run "${FZF_MENU}" nope
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"no such menu: nope"* ]]
  [[ "${output}" == *"demo"* ]]
}

@test "a missing argument exits 2 with usage" {
  run "${FZF_MENU}"
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"Usage:"* ]]
}

@test "a line with no tab is skipped with a warning" {
  printf '# Broken\nnotabhere\nStatus\techo ok\n' > "${FZF_MENU_DIR}/broken.menu"
  export FZF_STUB_SELECTION=$'echo ok\tStatus'
  run "${FZF_MENU}" broken
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"broken.menu:2"* ]]
}

@test "comment lines after the header are ignored" {
  printf '# Head\n# a note\nStatus\techo ok\n' > "${FZF_MENU_DIR}/noted.menu"
  export FZF_STUB_SELECTION=$'echo ok\tStatus'
  run "${FZF_MENU}" noted
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" != *"a note"* ]]
}

@test "aborting the picker exits 0 and runs nothing" {
  export FZF_STUB_ABORT=1
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
}

@test "--help exits 0" {
  run "${FZF_MENU}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
