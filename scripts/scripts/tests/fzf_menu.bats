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
  # Short client by default, so the tests written for the fzf popup keep
  # exercising it. The native-menu tests raise it explicitly. With
  # MENU_CHROME_ROWS at 4, a height of 4 cannot fit even one item.
  export TMUX_STUB_CLIENT_HEIGHT=4
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

@test "entries are numbered and bound to digit keys" {
  export FZF_STUB_SELECTION=$'echo hidden-command-ran\t2 Status'
  run "${FZF_MENU}" demo
  [ "${status}" -eq 0 ]
  run fzf_args
  # Two entries in the demo menu, so two binds and no third.
  [[ "${output}" == *"1:pos(1)+accept,2:pos(2)+accept"* ]]
  [[ "${output}" != *"3:pos(3)"* ]]
}

@test "digit binds stop at the number of entries" {
  printf '# One\nOnly\techo one\n' > "${FZF_MENU_DIR}/one.menu"
  export FZF_STUB_SELECTION=$'echo one\t1 Only'
  run "${FZF_MENU}" one
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" == *"1:pos(1)+accept"* ]]
  [[ "${output}" != *"2:pos(2)"* ]]
}

@test "labels are the display column and commands are hidden" {
  export FZF_STUB_SELECTION=$'echo hidden-command-ran\t2 Status'
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
@test "--explain shows the command alone, bare" {
  run "${FZF_MENU}" --explain "git status"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | head -1)" = "git status" ]
  [ "$(printf '%s' "${output}" | grep -c .)" -eq 1 ]
}

@test "--explain strips @window" {
  run "${FZF_MENU}" --explain "@window git rebase -i origin/main"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | head -1)" = "git rebase -i origin/main" ]
}

@test "--explain strips @pane" {
  run "${FZF_MENU}" --explain "@pane ls -la"
  [ "$(printf '%s' "${output}" | head -1)" = "ls -la" ]
}

@test "--explain strips @bg" {
  run "${FZF_MENU}" --explain "@bg gh pr view --web"
  [ "$(printf '%s' "${output}" | head -1)" = "gh pr view --web" ]
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
  printf '%s\n' "${output}" | assert_arg_after "-h" "9"
}

@test "--popup height is capped at POPUP_MAX_ITEMS entries" {
  setup_tmux_stub
  printf '# Many\n' > "${FZF_MENU_DIR}/many.menu"
  local i
  for i in $(seq 1 40); do
    printf 'E%s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/many.menu"
  done
  run "${FZF_MENU}" --popup many
  [ "${status}" -eq 0 ]
  run tmux_call_args "display-popup"
  printf '%s\n' "${output}" | assert_arg_after "-h" "21"
}

@test "--popup on a missing menu exits 2 without opening anything" {
  setup_tmux_stub
  run "${FZF_MENU}" --popup nope
  [ "${status}" -eq 2 ]
  run refute_tmux_subcommand "display-popup"
  [ "${status}" -eq 0 ]
}

# The menu asks for one frame instead of .fzfrc's box-per-section, which is
# right for a file finder and four nested borders too many for six entries.
@test "the menu asks for a single frame and drops fzfrc padding" {
  setup_fzf_stub
  export FZF_STUB_SELECTION=$'echo hi\tSay hi'
  printf '# P\nSay hi\techo hi\n' > "${FZF_MENU_DIR}/pad.menu"
  run "${FZF_MENU}" pad
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--padding" "0"
  printf '%s\n' "${output}" | assert_arg_after "--style" "default"
  printf '%s\n' "${output}" | assert_arg_after "--info" "hidden"
  [[ "${output}" != *"--preview-label"* ]]
}

# menu.menu chains into the five leaf menus. Without a sigil for it, a
# chaining row would run under the bare case: it would work, but it would
# pause for a keypress on the way out of a menu the user is still using.
# A queue, not a single forced selection: the chain picks twice, and one
# forced value would be replayed by the child menu too - which for @menu is an
# infinite exec loop, not a failed assertion.
@test "@menu runs the target menu" {
  printf '# Leaf\nOnly\techo leaf-ran\n' > "${FZF_MENU_DIR}/leaf.menu"
  printf '# Menus\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export FZF_STUB_SELECTIONS="$(printf '@menu leaf\t1 Leaf\necho leaf-ran\t1 Only')"
  run "${FZF_MENU}" top
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"leaf-ran"* ]]
}

@test "@menu does not pause for a keypress on the way out" {
  printf '# Leaf\nOnly\t@bg true\n' > "${FZF_MENU_DIR}/leaf.menu"
  printf '# Menus\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export FZF_STUB_SELECTIONS="$(printf '@menu leaf\t1 Leaf\n@bg true\t1 Only')"
  run "${FZF_MENU}" top
  [[ "${output}" != *"Press any key"* ]]
}

# Two menus naming each other would exec back and forth forever, and inside a
# tmux popup that looks like a hang with nothing to interrupt.
@test "an @menu cycle stops instead of looping forever" {
  printf '# A\nB\t@menu bbb\n' > "${FZF_MENU_DIR}/aaa.menu"
  printf '# B\nA\t@menu aaa\n' > "${FZF_MENU_DIR}/bbb.menu"
  export FZF_STUB_SELECTIONS="$(printf '@menu bbb\t1 B\n@menu aaa\t1 A')"
  run timeout 20 "${FZF_MENU}" aaa
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"too deep"* ]]
}

@test "--explain names the menu an @menu row opens" {
  run "${FZF_MENU}" --explain "@menu worktree"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"worktree"* ]]
  [[ "${output}" != *"UNKNOWN SIGIL"* ]]
}

@test "@menu is not mistaken for an unknown sigil" {
  run "${FZF_MENU}" --explain "@menu git"
  [[ "${output}" != *"UNKNOWN SIGIL"* ]]
}

# popup() sizes the box before fzf-menu runs inside it. A two-row menu that
# chains into a nine-row one must be built for nine, or the target scrolls.
@test "popup sizes to the tallest @menu target, not its own rows" {
  printf '# Big\nA\techo a\nB\techo b\nC\techo c\nD\techo d\nE\techo e\n' \
    > "${FZF_MENU_DIR}/big.menu"
  printf '# Menus\nBig\t@menu big\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  # 5 rows + POPUP_CHROME_ROWS(6) = 11, not 1 + 6 = 7.
  printf '%s\n' "${output}" | assert_arg_after "-h" "11"
}

@test "popup keeps its own rows when they are the tallest" {
  printf '# Small\nA\techo a\n' > "${FZF_MENU_DIR}/small.menu"
  printf '# Menus\nA\techo a\nB\techo b\nC\techo c\nSmall\t@menu small\n' \
    > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  run tmux_call_args display-popup
  # 4 own rows beats the 1-row target: 4 + 6 = 10.
  printf '%s\n' "${output}" | assert_arg_after "-h" "10"
}

@test "popup still clamps a tall @menu target at POPUP_MAX_ITEMS" {
  printf '# Huge\n' > "${FZF_MENU_DIR}/huge.menu"
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/huge.menu"
  done
  printf '# Menus\nHuge\t@menu huge\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  run tmux_call_args display-popup
  # Clamped to POPUP_MAX_ITEMS(15) + 6 = 21.
  printf '%s\n' "${output}" | assert_arg_after "-h" "21"
}

@test "popup ignores an @menu target that does not exist" {
  printf '# Menus\nGone\t@menu nosuch\nA\techo a\n' > "${FZF_MENU_DIR}/top.menu"
  run "${FZF_MENU}" --popup top
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  # Falls back to its own 2 rows: 2 + 6 = 8.
  printf '%s\n' "${output}" | assert_arg_after "-h" "8"
}

# fzf's `transform-preview-label:` consumes everything after the colon as its
# command, to the end of the --bind string, commas included. When it came
# first, every digit binding after it was swallowed into that command and no
# number key did anything. fzf reports no error for this, so the argv
# assertions above all passed while the feature was dead.
@test "the digit binds come before the transform, not after" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\t1 Fetch'
  run "${FZF_MENU}" demo
  run fzf_args
  local binds
  binds="$(printf '%s\n' "${output}" | grep -m1 'pos(1)')"
  [[ "${binds}" == "1:pos(1)+accept"* ]]
  [[ "${binds}" == *"transform-preview-label"* ]]
  # The transform must be the last thing in the string.
  [[ "${binds}" == *"focus:transform-preview-label:true" ]]
}

# The assertion above is about ordering; this one proves the ordering actually
# buys a parsed binding, by asking real fzf to reject a bogus action sitting
# in the digit slot. If the digit slot were being swallowed, fzf would accept
# it silently - which is exactly the bug that shipped.
@test "real fzf parses the digit slot as a binding, not as text" {
  # setup_fzf_stub puts the stub first on PATH, and the stub accepts anything.
  # This test is only worth running against the real binary.
  local real_fzf
  real_fzf="$(PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin" \
    command -v fzf 2>/dev/null || true)"
  if [ -z "${real_fzf}" ]; then
    skip "real fzf not installed"
  fi
  run bash -c "printf 'a\n' | '${real_fzf}' --bind '1:bogus-action,focus:transform-preview-label:true' --filter=a 2>&1"
  [[ "${output}" == *"unknown action"* ]]
}

# The menu popup hosts a bare command's output as well as the picker, so it
# keeps tmux's border - that is what separates the output from the pane
# behind. fzf must then not draw a second one inside it.
@test "the menu popup keeps its tmux border" {
  run "${FZF_MENU}" --popup demo
  run tmux_call_args display-popup
  [[ "${output}" != *"-B"* ]]
}

@test "fzf draws no border of its own inside it" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\t1 Fetch'
  run "${FZF_MENU}" demo
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--border" "none"
}

# The blank ring existed only to keep the tearing row empty on a borderless
# popup. With tmux drawing the border it is a wasted row inside it.
@test "the menu picker asks for no margin" {
  export FZF_STUB_SELECTION=$'echo fetch-ran\t1 Fetch'
  run "${FZF_MENU}" demo
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--margin" "0"
}

# A menu item has no popup to write into, so a bare command opens its own.
@test "--run on a bare command opens a popup" {
  run "${FZF_MENU}" --run "echo hi"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"echo hi"* ]]
}

# Bordered, like the other popups that show command output.
@test "--run's popup keeps its border" {
  run "${FZF_MENU}" --run "echo hi"
  run tmux_call_args display-popup
  [[ "${output}" != *"-B"* ]]
}

@test "--run's popup waits for a key so output can be read" {
  run "${FZF_MENU}" --run "echo hi"
  run tmux_call_args display-popup
  [[ "${output}" == *"Press any key"* ]]
}

@test "--run honours @window without a popup" {
  run "${FZF_MENU}" --run "@window vim"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand new-window
  refute_tmux_subcommand display-popup
}

@test "--run honours @pane without a popup" {
  run "${FZF_MENU}" --run "@pane ls -la"
  assert_tmux_subcommand send-keys
  refute_tmux_subcommand display-popup
}

@test "--run honours @bg without a popup" {
  run "${FZF_MENU}" --run "@bg true"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-popup
}

@test "--run rejects an unknown sigil" {
  run "${FZF_MENU}" --run "@nope echo hi"
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"unknown sigil"* ]]
}

@test "--run with no command is a usage error" {
  run "${FZF_MENU}" --run
  [ "${status}" -eq 2 ]
}

@test "--popup renders a native menu when the rows fit" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup demo
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}

# The whole entry travels as ONE argument to --run, so it arrives escaped.
# Asserting on the unescaped text would be asserting on the bug.
@test "the native menu's items call --run with the whole entry" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup demo
  run tmux_call_args display-menu
  [[ "${output}" == *"--run"* ]]
  [[ "${output}" == *'echo\ fetch-ran'* ]]
}

# menu_rows numbers labels for fzf's benefit; tmux draws the key itself, so a
# native menu must not carry the number as well.
@test "the native menu's labels are not numbered" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup demo
  run tmux_call_args display-menu
  [[ "${output}" == *"Fetch"* ]]
  [[ "${output}" != *"1 Fetch"* ]]
}

@test "--popup falls back to fzf when the rows do not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=5
  printf '# Big\n' > "${FZF_MENU_DIR}/big.menu"
  local i
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/big.menu"
  done
  run "${FZF_MENU}" --popup big
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-popup
  refute_tmux_subcommand display-menu
}

# A chaining menu has to fit the tallest screen it can reach, not just its own
# rows, or picking a leaf blanks it.
@test "--popup measures an @menu target for the fit test too" {
  printf '# Leaf\n' > "${FZF_MENU_DIR}/leaf.menu"
  local i
  for i in $(seq 1 30); do
    printf 'Row %s\techo %s\n' "${i}" "${i}" >> "${FZF_MENU_DIR}/leaf.menu"
  done
  printf '# Top\nLeaf\t@menu leaf\n' > "${FZF_MENU_DIR}/top.menu"
  export TMUX_STUB_CLIENT_HEIGHT=12
  run "${FZF_MENU}" --popup top
  refute_tmux_subcommand display-menu
  assert_tmux_subcommand display-popup
}

@test "--popup on a missing menu still exits 2 without rendering" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run "${FZF_MENU}" --popup nosuch
  [ "${status}" -eq 2 ]
  refute_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}

# @pick is for commands that draw their own menu or popup. Wrapping one in a
# popup is what made "Review PR" open an empty box: a display-menu cannot be
# drawn while a popup is already up.
@test "@pick runs the command without a popup of its own" {
  run "${FZF_MENU}" --run "@pick echo picked"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"picked"* ]]
  refute_tmux_subcommand display-popup
}

@test "@pick does not pause for a keypress" {
  run "${FZF_MENU}" --run "@pick echo picked"
  [[ "${output}" != *"Press any key"* ]]
}

@test "@pick is not mistaken for an unknown sigil" {
  run "${FZF_MENU}" --explain "@pick pr-pick review"
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"UNKNOWN SIGIL"* ]]
  [[ "${output}" == *"pr-pick review"* ]]
}

@test "a failing @pick reports it without failing the menu" {
  run "${FZF_MENU}" --run "@pick exit 3"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"picker exited"* ]]
}

# The pause prompt is what the user reads after a bare command finishes.
@test "the bare-command popup names Escape as a way out" {
  run "${FZF_MENU}" --run "echo hi"
  run tmux_call_args display-popup
  [[ "${output}" == *"Esc"* ]]
}
