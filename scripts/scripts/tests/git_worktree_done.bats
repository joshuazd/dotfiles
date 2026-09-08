#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  setup_cmd_stubs
  export TMUX_STUB_LIST_SESSIONS="$(printf '200|other\n100|current')"
  export TMUX_STUB_DISPLAY="current"
  DONE="${BATS_TEST_DIRNAME}/../git-worktree-done"
}

# The gate is a separate script so prefix d and wt-pick reach the same one.
# SCRIPTS_PKG_DIR points sibling lookups at a recorder instead, the same way
# FZF_MENU_DIR redirects fzf-menu in its own suite. This keeps these tests
# about the wiring rather than about the prompt, which wt_confirm.bats covers.
use_gate() {
  stub_cmd wt-confirm "" "${1}"
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
}

@test "a cancelled confirmation switches no client" {
  use_gate 1
  run "${DONE}"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand switch-client
}

@test "a cancelled confirmation opens no cleanup popup" {
  use_gate 1
  run "${DONE}"
  refute_tmux_subcommand display-popup
}

# run-shell -b surfaces this script's stdout in the pane, where it outlives
# the popup the user just dismissed. A cancel has to leave nothing behind.
@test "a cancelled confirmation prints nothing" {
  use_gate 1
  run "${DONE}"
  [ -z "${output}" ]
}

# The gate is handed the rest of this script as an action rather than asked
# for an answer: `tmux display-menu` does not reliably block until its menu is
# answered, so a status read afterwards always said cancel. Nothing destructive
# may therefore happen on THIS pass, only in the --confirmed re-entry.
@test "asking the gate switches nothing by itself" {
  use_gate 0
  run "${DONE}"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand switch-client
  refute_tmux_subcommand display-popup
}

@test "the gate is handed this script as the action" {
  use_gate 0
  run "${DONE}"
  run cmd_call_args wt-confirm
  [[ "${output}" == *"--run"* ]]
  [[ "${output}" == *"git-worktree-done --confirmed"* ]]
}

# The re-entry runs under a menu item's run-shell, by which point the focused
# pane is whatever the user is looking at - which need not be the worktree the
# menu named. So the agreed path and session travel with it.
@test "the action names the worktree and session it agreed to" {
  use_gate 0
  run "${DONE}"
  run cmd_call_args wt-confirm
  [[ "${output}" == *"--confirmed"*"current"* ]]
}

@test "a confirmed removal switches the client" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand switch-client
}

@test "a confirmed removal opens the cleanup popup" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  assert_tmux_subcommand display-popup
}

@test "a confirmed removal does not ask again" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  refute_cmd_called wt-confirm
}

@test "the confirmed removal acts on the worktree it was given" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  run tmux_call_args display-popup
  [[ "${output}" == *"/tmp/agreed-worktree"* ]]
}

# The switch has to land before the popup, or cleanup kills the session the
# popup is drawn in.
@test "the client switches before the cleanup popup" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  [ "$(tmux_call_index switch-client '')" -lt "$(tmux_call_index display-popup '')" ]
}

@test "the gate is asked at all" {
  use_gate 0
  run "${DONE}"
  assert_cmd_called wt-confirm
}

@test "the gate is told which session is at stake" {
  use_gate 0
  run "${DONE}"
  run cmd_call_args wt-confirm
  [[ "${output}" == *"current"* ]]
}

# Nothing may be destroyed by a gate that could not run.
@test "a missing gate is a hard error, not a silent proceed" {
  export SCRIPTS_PKG_DIR="${BATS_TEST_TMPDIR}/empty-pkg"
  run "${DONE}"
  [ "${status}" -eq 1 ]
  refute_tmux_subcommand switch-client
}

# This popup shows scrolling command output, so it keeps its border: that is
# what separates it from the pane behind. A picker gets the same from fzf's
# own frame and passes -B instead.
@test "the cleanup popup keeps its border" {
  use_gate 0
  run "${DONE}"
  run tmux_call_args display-popup
  [[ "${output}" != *"-B"* ]]
}
