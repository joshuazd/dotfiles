#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  source "${BATS_TEST_DIRNAME}/../lib/tmux.sh"
}

@test "session_name_from_title strips tmux-unsafe characters" {
  run session_name_from_title "SC" "12345" "Emit metrics: for v1.2 'now'"
  [ "${status}" -eq 0 ]
  [ "${output}" = "SC-12345 Emit metrics for v12 now" ]
}

@test "session_name_from_title truncates at a word boundary" {
  run session_name_from_title "SC" "12345" "Refactor the entire authentication subsystem end to end"
  [ "${status}" -eq 0 ]
  [ "${#output}" -le 50 ]
  [[ "${output}" != *" " ]]
}

@test "tmux stub records invocations" {
  tmux display-message -p "hello world"
  run tmux_calls
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"display-message"* ]]
  [[ "${output}" == *"hello world"* ]]
}

@test "refute_tmux_subcommand fails when the subcommand was used" {
  tmux send-keys -t target "echo hi" Enter
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -ne 0 ]
}

@test "assert_tmux_subcommand fails when the subcommand was not used" {
  run assert_tmux_subcommand "respawn-pane"
  [ "${status}" -ne 0 ]
}

@test "tmux_call_args splits arguments containing spaces" {
  tmux respawn-pane -k -t "=SC-1 demo:claude.1" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
  [[ "${output}" == *"claude --model opus"* ]]
  [ "$(printf '%s' "${output}" | grep -c .)" -eq 5 ]
}
