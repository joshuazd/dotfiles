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
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
}

@test "a cancelled confirmation switches no client" {
  use_gate 1
  run "${DONE}"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand switch-client
}

@test "a cancelled confirmation cleans up nothing" {
  use_gate 1
  run "${DONE}"
  refute_cmd_called git-worktree-cleanup
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
  refute_cmd_called git-worktree-cleanup
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

@test "a confirmed removal runs the cleanup" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  assert_cmd_called git-worktree-cleanup
}

# Fire-and-forget: the confirmation already happened and the session leaving
# vigil's list is the feedback. This ran in a display-popup from 2026-03-02
# until it was removed - a box appearing after every `prefix d` is worse than
# cleanup output nobody reads.
@test "a confirmed removal opens no popup" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  refute_tmux_subcommand display-popup
}

@test "a confirmed removal does not ask again" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  refute_cmd_called wt-confirm
}

@test "the confirmed removal acts on the worktree it was given" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  run cmd_call_args git-worktree-cleanup
  [[ "${output}" == *"/tmp/agreed-worktree"* ]]
  [[ "${output}" == *"current"* ]]
}

# The switch has to land first, or cleanup kills the session the client is
# still attached to.
@test "the client switches before the cleanup" {
  use_gate 0
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  assert_tmux_subcommand switch-client
  assert_cmd_called git-worktree-cleanup
  # The two live in different call logs, so ordering is pinned by the pair
  # above plus "asking the gate switches nothing by itself".
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

# prefix d must stay a keypress with one question and no boxes. This is the
# guard for that as a whole, not just for the popup that was removed.
@test "prefix d opens no popup on any pass" {
  use_gate 0
  run "${DONE}"
  refute_tmux_subcommand display-popup
  run "${DONE}" --confirmed /tmp/agreed-worktree current
  refute_tmux_subcommand display-popup
}
