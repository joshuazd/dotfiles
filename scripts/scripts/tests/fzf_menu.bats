#!/usr/bin/env bats

load helper

# Fixtures deliberately use `echo`, never real git commands. Task 3 makes a
# bare command actually execute, and a fixture that shells out to git would
# turn this suite into a slow, side-effecting one the moment that lands.

setup() {
  setup_fzf_stub
  setup_tmux_stub
  export FZF_MENU_DIR="${BATS_TEST_TMPDIR}/menus"
  mkdir -p "${FZF_MENU_DIR}"
  MENU="${FZF_MENU_DIR}/demo.menu"
  printf '# Demo actions\nFetch\techo fetch-ran\nStatus\techo hidden-command-ran\n' > "${MENU}"
  FZF_MENU="${BATS_TEST_DIRNAME}/../fzf-menu"
}

# The menu file's first line becomes the PROMPT, not a --header: a header
# under --style full is a bordered section of its own, which is a lot of
# furniture for six self-evident rows.
@test "the prompt comes from the first comment line" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "Demo actions> "
  [[ "${output}" != *"--header"* ]]
}

@test "a menu without a header comment falls back to the menu name" {
  printf 'Fetch\techo fetch-ran\n' > "${FZF_MENU_DIR}/bare.menu"
  export FZF_STUB_SELECTION=$'echo fetch-ran\tFetch'
  run "${FZF_MENU}" bare
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "bare> "
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

@test "an unavailable picker exits 2, not 0" {
  PICKER_PATH_DIRS="" PATH="/usr/bin:/bin" run "${FZF_MENU}" demo
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${FZF_MENU}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}

@test "@window opens a new tmux window" {
  setup_tmux_stub
  printf '# Win\nEdit\t@window vim\n' > "${FZF_MENU_DIR}/win.menu"
  export FZF_STUB_SELECTION=$'@window vim\tEdit'
  run "${FZF_MENU}" win
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "new-window"
  [ "${status}" -eq 0 ]
  run tmux_call_args "new-window"
  [[ "${output}" == *"vim"* ]]
  [[ "${output}" != *"@window"* ]]
}

@test "a failing @window reports a warning and does not fail the menu" {
  setup_tmux_stub
  export TMUX_STUB_NEW_WINDOW_FAILS=1
  printf '# Win\nEdit\t@window vim\n' > "${FZF_MENU_DIR}/win2.menu"
  export FZF_STUB_SELECTION=$'@window vim\tEdit'
  run "${FZF_MENU}" win2
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"new-window failed"* ]]
}

@test "@pane sends keys to the current pane" {
  setup_tmux_stub
  printf '# Pane\nList\t@pane ls -la\n' > "${FZF_MENU_DIR}/pane.menu"
  export FZF_STUB_SELECTION=$'@pane ls -la\tList'
  run "${FZF_MENU}" pane
  [ "${status}" -eq 0 ]
  run tmux_call_args "send-keys"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"-l"* ]]
  [[ "${output}" == *"ls -la"* ]]
  run tmux_call_args_matching "send-keys" "Enter"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Enter"* ]]
}

@test "a failing @pane reports a warning and does not fail the menu" {
  setup_tmux_stub
  export TMUX_STUB_SEND_KEYS_FAILS=1
  printf '# Pane\nList\t@pane ls -la\n' > "${FZF_MENU_DIR}/pane2.menu"
  export FZF_STUB_SELECTION=$'@pane ls -la\tList'
  run "${FZF_MENU}" pane2
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"send-keys failed"* ]]
}

@test "@bg runs detached and reports the log path" {
  setup_tmux_stub
  printf '# Bg\nTouch\t@bg touch %s/bg-ran\n' "${BATS_TEST_TMPDIR}" \
    > "${FZF_MENU_DIR}/bg.menu"
  export FZF_STUB_SELECTION="$(printf '@bg touch %s/bg-ran\tTouch' "${BATS_TEST_TMPDIR}")"
  run "${FZF_MENU}" bg
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"background"* ]]
}

@test "an unknown sigil exits 2 without running the line" {
  setup_tmux_stub
  printf '# Bad\nOops\t@nope echo hi\n' > "${FZF_MENU_DIR}/bad.menu"
  export FZF_STUB_SELECTION=$'@nope echo hi\tOops'
  run "${FZF_MENU}" bad
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"unknown sigil"* ]]
  run refute_tmux_subcommand "new-window"
  [ "${status}" -eq 0 ]
}

@test "a bare command runs in the popup and reports a nonzero status" {
  setup_tmux_stub
  printf '# Bare\nFail\texit 3\n' > "${FZF_MENU_DIR}/bare2.menu"
  export FZF_STUB_SELECTION=$'exit 3\tFail'
  run "${FZF_MENU}" bare2
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"exited 3"* ]]
}

@test "a bare command's output is shown and does not block without a tty" {
  setup_tmux_stub
  printf '# Bare\nSay\techo bare-ran\n' > "${FZF_MENU_DIR}/bare3.menu"
  export FZF_STUB_SELECTION=$'echo bare-ran\tSay'
  run "${FZF_MENU}" bare3
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"bare-ran"* ]]
  [[ "${output}" != *"Press any key"* ]]
}

# The bare (no sigil) case is the one a packed "sigil<TAB>body" return value
# silently broke: tab is IFS whitespace, so the leading empty field collapsed
# and the command's first word was read as the sigil.
@test "--explain shows the command and where it runs, bare" {
  run "${FZF_MENU}" --explain "git status"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | head -1)" = "git status" ]
  [[ "${output}" == *"runs here"* ]]
}

@test "--explain strips @window and names the destination" {
  run "${FZF_MENU}" --explain "@window git rebase -i origin/main"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | head -1)" = "git rebase -i origin/main" ]
  [[ "${output}" == *"new tmux window"* ]]
}

@test "--explain strips @pane" {
  run "${FZF_MENU}" --explain "@pane ls -la"
  [ "$(printf '%s' "${output}" | head -1)" = "ls -la" ]
  [[ "${output}" == *"current pane"* ]]
}

@test "--explain strips @bg and names the log" {
  run "${FZF_MENU}" --explain "@bg gh pr view --web"
  [ "$(printf '%s' "${output}" | head -1)" = "gh pr view --web" ]
  [[ "${output}" == *"detached"* ]]
}

@test "--explain flags an unknown sigil instead of pretending it will run" {
  run "${FZF_MENU}" --explain "@nope oops"
  [[ "${output}" == *"UNKNOWN SIGIL"* ]]
}

@test "--popup height grows with the entry count" {
  setup_tmux_stub
  printf '# Three\nA\techo a\nB\techo b\nC\techo c\n' > "${FZF_MENU_DIR}/three.menu"
  run "${FZF_MENU}" --popup three
  [ "${status}" -eq 0 ]
  run tmux_call_args "display-popup"
  printf '%s\n' "${output}" | assert_arg_after "-h" "17"
}

@test "--popup height is capped for a long menu" {
  setup_tmux_stub
  printf '# Many\n' > "${FZF_MENU_DIR}/many.menu"
  local i
  for i in $(seq 1 40); do
    printf 'E%s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/many.menu"
  done
  run "${FZF_MENU}" --popup many
  [ "${status}" -eq 0 ]
  run tmux_call_args "display-popup"
  printf '%s\n' "${output}" | assert_arg_after "-h" "32"
}

@test "--popup on a missing menu exits 2 without opening anything" {
  setup_tmux_stub
  run "${FZF_MENU}" --popup nope
  [ "${status}" -eq 2 ]
  run refute_tmux_subcommand "display-popup"
  [ "${status}" -eq 0 ]
}
