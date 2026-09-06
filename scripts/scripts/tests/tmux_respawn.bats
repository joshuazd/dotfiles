#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  RESPAWN="${BATS_TEST_DIRNAME}/../tmux-respawn"
}

@test "confirming respawns the pane" {
  export FZF_STUB_SELECTION=$'confirm\t2 Kill the process and respawn'
  run "${RESPAWN}"
  assert_tmux_subcommand respawn-pane
}

@test "the respawn is killed and targeted explicitly" {
  export FZF_STUB_SELECTION=$'confirm\t2 Kill the process and respawn'
  run "${RESPAWN}"
  run tmux_call_args respawn-pane
  [[ "${output}" == *"-k"* ]]
  printf '%s\n' "${output}" | assert_arg_after "-t" "@3"
}

@test "cancelling respawns nothing" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
}

# Cancel is the first row, so it is the cursor position and the Enter answer.
@test "Enter on an unmoved cursor cancels" {
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
}

@test "escaping respawns nothing" {
  export FZF_STUB_ABORT=1
  run "${RESPAWN}"
  refute_tmux_subcommand respawn-pane
}

# Nothing to read afterwards, so the popup should close rather than pause.
@test "every no-op path closes quietly" {
  export FZF_STUB_ABORT=1
  run "${RESPAWN}"
  [ "${status}" -eq 97 ]
}

@test "a completed respawn also closes quietly" {
  export FZF_STUB_SELECTION=$'confirm\t2 Kill the process and respawn'
  run "${RESPAWN}"
  [ "${status}" -eq 97 ]
}

@test "the prompt names what is about to be killed" {
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
