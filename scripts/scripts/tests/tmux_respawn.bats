#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  RESPAWN="${BATS_TEST_DIRNAME}/../tmux-respawn"
}

# A client too short for the confirm menu is the only thing that reaches fzf.
# Everything else asks natively, so a test wanting the fallback has to say so.
short_client() {
  export TMUX_STUB_CLIENT_HEIGHT=1
}

# The menu item carries the respawn, so the native path never calls
# respawn-pane itself: display-menu does not reliably block until its menu is
# answered, and a version that waited for one always cancelled.
@test "the confirming item is the respawn" {
  run "${RESPAWN}"
  run tmux_call_args display-menu
  [[ "${output}" == *"run-shell -b"* ]]
  [[ "${output}" == *"respawn-pane -k -t"* ]]
  [[ "${output}" == *"@3"* ]]
}

@test "the native path kills nothing by itself" {
  run "${RESPAWN}"
  assert_tmux_subcommand display-menu
  refute_tmux_subcommand respawn-pane
}

@test "confirming is bound to y and cancelling to n" {
  run "${RESPAWN}"
  run tmux_call_args display-menu
  printf '%s\n' "${output}" | assert_arg_after "Cancel" "n"
  printf '%s\n' "${output}" | assert_arg_after "Kill the process and respawn" "y"
}

# Cancel is the first choice, so it is the cursor position and the Enter answer.
@test "cancel is offered before the destructive choice" {
  run "${RESPAWN}"
  run tmux_call_args display-menu
  local cancel_at="${output%%Cancel*}"
  local kill_at="${output%%Kill the process*}"
  [ "${#cancel_at}" -lt "${#kill_at}" ]
}

@test "the menu names what is about to be killed" {
  run "${RESPAWN}"
  run tmux_call_args display-menu
  [[ "${output}" == *"running:"* ]]
}

# The information row is dim and unselectable, which is the whole reason it can
# carry detail without becoming an answer.
@test "the detail row is a disabled item" {
  run "${RESPAWN}"
  run tmux_call_args display-menu
  [[ "${output}" == *"-running:"* ]]
}

@test "the native path closes quietly" {
  run "${RESPAWN}"
  [ "${status}" -eq 97 ]
}

@test "a client too short for the menu falls back to fzf" {
  short_client
  export FZF_STUB_SELECTION=$'confirm\t2 Kill the process and respawn'
  run "${RESPAWN}"
  assert_tmux_subcommand respawn-pane
  refute_tmux_subcommand display-menu
}

# On the fallback there is no menu item to carry the action, so this path is
# the only one that runs the respawn itself.
@test "the fzf fallback targets the pane explicitly" {
  short_client
  export FZF_STUB_SELECTION=$'confirm\t2 Kill the process and respawn'
  run "${RESPAWN}"
  run tmux_call_args respawn-pane
  [[ "${output}" == *"-k"* ]]
  printf '%s\n' "${output}" | assert_arg_after "-t" "@3"
}

@test "the fzf fallback cancels on a cancel row" {
  short_client
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
}

# Cancel is the first row, so it is the cursor position and the Enter answer.
@test "the fzf fallback cancels on an unmoved cursor" {
  short_client
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
}

@test "the fzf fallback cancels on escape" {
  short_client
  export FZF_STUB_ABORT=1
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
  [ "${status}" -eq 97 ]
}

@test "the fzf fallback names what is about to be killed" {
  short_client
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${RESPAWN}"
  run fzf_args
  [[ "${output}" == *"running:"* ]]
}

@test "outside tmux it refuses" {
  unset TMUX
  run "${RESPAWN}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${RESPAWN}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
