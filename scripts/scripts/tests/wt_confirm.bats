#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  WT_CONFIRM="${BATS_TEST_DIRNAME}/../wt-confirm"
  REPO="${BATS_TEST_TMPDIR}/repo"
  RAN="${BATS_TEST_TMPDIR}/ran"
  ACTION="touch $(printf '%q' "${RAN}")"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q
  git -C "${REPO}" config user.email t@example.com
  git -C "${REPO}" config user.name Test
  printf 'one\n' > "${REPO}/file.txt"
  git -C "${REPO}" add file.txt
  git -C "${REPO}" commit -qm first
}

# With no tty the gate asks with a native display-menu, so the popup path only
# runs when a menu cannot be drawn: outside tmux, or on a client too short.
short_client() {
  export TMUX_STUB_CLIENT_HEIGHT=1
}

assert_action_ran() {
  [ -e "${RAN}" ]
}

refute_action_ran() {
  [ ! -e "${RAN}" ]
}

# --- the inline picker path -----------------------------------------------

@test "picking Remove runs the action" {
  export FZF_STUB_SELECTION=$'confirm\t2 Remove worktree and kill session'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  [ "${status}" -eq 0 ]
  assert_action_ran
}

@test "picking Cancel runs nothing" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  [ "${status}" -eq 1 ]
  refute_action_ran
}

@test "escaping runs nothing" {
  export FZF_STUB_ABORT=1
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  [ "${status}" -eq 1 ]
  refute_action_ran
}

# Cancel is offered first so it is where the cursor starts and what Enter
# answers. A destructive default is the whole bug this script exists to fix.
# With no forced selection the stub returns the first row it was handed, which
# is exactly the Enter-key behavior under test.
@test "Enter on an unmoved cursor cancels" {
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  [ "${status}" -eq 1 ]
  refute_action_ran
}

# Quoted, so the name's boundaries are visible against the rest of the prompt.
@test "the prompt names the session in quotes" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"'repo-session'"* ]]
}

@test "the header names the path" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"${REPO}"* ]]
}

@test "the header reports uncommitted work" {
  printf 'dirty\n' > "${REPO}/scratch.txt"
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"1 uncommitted file"* ]]
}

@test "the header says clean when nothing is at risk" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"clean"* ]]
}

@test "--inline never opens a popup" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  refute_tmux_subcommand display-popup
}

@test "the confirm picker keeps its margin" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}" repo-session
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--margin" "1,1,0,1"
}

# --- the native menu path -------------------------------------------------

# The menu ITEM carries the action. Nothing is read back, because display-menu
# does not reliably block until its menu is answered - measured returning 0 a
# second after opening with the menu untouched, which made the old gate report
# a cancel every time and looked like a confirm that did nothing.
@test "with no tty the gate asks with a native menu" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}

@test "the confirming item carries the action" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  [[ "${output}" == *"run-shell -b"* ]]
  [[ "${output}" == *"${RAN}"* ]]
}

@test "the gate itself runs nothing on the native path" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  refute_action_ran
}

@test "no answer variable is used" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  refute_tmux_subcommand set-environment
  refute_tmux_subcommand show-environment
}

@test "the native menu names the session in quotes" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  [[ "${output}" == *"'repo-session'"* ]]
}

# Each fact gets a dim row of its own rather than being crammed into one line.
# tmux refuses to select a name beginning with a hyphen, which is what makes
# them safe to list above the choices.
@test "the native menu carries the path as a disabled row" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  [[ "${output}" == *"-${REPO}"* ]]
}

@test "the native menu carries the branch" {
  git -C "${REPO}" checkout -q -b feature/thing
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  [[ "${output}" == *"on feature/thing"* ]]
}

@test "the native menu reports uncommitted work" {
  printf 'dirty\n' > "${REPO}/scratch.txt"
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  [[ "${output}" == *"1 uncommitted file"* ]]
}

@test "the native menu binds y to remove and n to cancel" {
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Cancel" "n"
  printf '%s\n' "${output}" | assert_arg_after "Remove worktree and kill session" "y"
}

# --- the popup fallback ---------------------------------------------------

# -B, matching fzf-menu's popup: the picker draws its own frame, and a second
# tmux border around it is both redundant and the ring that tears.
@test "the popup is borderless" {
  short_client
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-popup
  [[ "${output}" == *"-B"* ]]
}

@test "with no tty and no room for a menu the gate opens a popup" {
  short_client
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"--inline"* ]]
  [[ "${output}" == *"--run"* ]]
}

# The action has to survive into the popup, or confirming there does nothing.
@test "the popup carries the action through" {
  short_client
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-popup
  [[ "${output}" == *"${RAN}"* ]]
}

@test "outside tmux the gate opens a popup rather than a menu" {
  unset TMUX
  run "${WT_CONFIRM}" --run "${ACTION}" "${REPO}" repo-session < /dev/null
  assert_tmux_subcommand display-popup
  refute_tmux_subcommand display-menu
}

# The popup starts in the client pane's directory, not the caller's, so a
# relative invocation path would not resolve inside it and the popup would die
# before drawing - which reads as an unexplained cancel.
@test "the popup re-enters by absolute path even when invoked relatively" {
  short_client
  cd "$(dirname "${WT_CONFIRM}")"
  run ./wt-confirm --run "${ACTION}" "${REPO}" repo-session < /dev/null
  run tmux_call_args display-popup
  [[ "${output}" == */wt-confirm* ]]
  [[ "${output}" != *"./wt-confirm"* ]]
}

# --- argument handling ----------------------------------------------------

@test "the session defaults to the directory basename" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --run "${ACTION}" "${REPO}"
  run fzf_args
  [[ "${output}" == *"repo"* ]]
}

@test "a missing worktree argument is a usage error" {
  run "${WT_CONFIRM}" --inline --run "${ACTION}"
  [ "${status}" -eq 2 ]
}

# Without an action there is nothing a confirm could do, and a gate that
# silently asked and then did nothing is the failure this design removed.
@test "a missing --run is a usage error" {
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 2 ]
}

@test "--run without a value is a usage error" {
  run "${WT_CONFIRM}" --inline "${REPO}" --run
  [ "${status}" -eq 2 ]
}

@test "an unknown option is a usage error" {
  run "${WT_CONFIRM}" --frobnicate
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${WT_CONFIRM}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
