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

@test "a cancelled confirmation says so" {
  use_gate 1
  run "${DONE}"
  [[ "${output}" == *"Cancelled"* ]]
}

@test "a confirmed removal switches the client" {
  use_gate 0
  run "${DONE}"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand switch-client
}

@test "a confirmed removal opens the cleanup popup" {
  use_gate 0
  run "${DONE}"
  assert_tmux_subcommand display-popup
}

# The switch has to land before the popup, or cleanup kills the session the
# popup is drawn in.
@test "the client switches before the cleanup popup" {
  use_gate 0
  run "${DONE}"
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
