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

@test "launch_claude_in_pane respawns the pane instead of sending keys" {
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -eq 0 ]
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"-k"* ]]
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
  [[ "${output}" == *"/tmp/wt"* ]]
}

@test "launch_claude_in_pane keeps a shell alive after claude exits" {
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"claude --model opus; exec "* ]]
}

@test "create_tmux_session launches claude without send-keys" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -eq 0 ]
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"claude --model opus"* ]]
}

@test "create_tmux_session with no claude command does not respawn" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true ""
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
}

@test "worktree_prompt_file resolves under the worktree git dir" {
  local wt="${BATS_TEST_TMPDIR}/wt"
  mkdir -p "${wt}"
  git -C "${wt}" init --quiet
  export TMUX_STUB_DISPLAY="${wt}"

  run worktree_prompt_file "SC-1 demo"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"/vigil-launch-prompt.txt" ]]
  [ -d "$(dirname "${output}")" ]
}

@test "worktree_prompt_file fails when the pane path is not a git dir" {
  export TMUX_STUB_DISPLAY="${BATS_TEST_TMPDIR}/not-a-repo"
  mkdir -p "${TMUX_STUB_DISPLAY}"

  run worktree_prompt_file "SC-1 demo"
  [ "${status}" -ne 0 ]
  [ -z "${output}" ]
}

@test "worktree_prompt_file queries the claude window pane path" {
  local wt="${BATS_TEST_TMPDIR}/wt2"
  mkdir -p "${wt}"
  git -C "${wt}" init --quiet
  export TMUX_STUB_DISPLAY="${wt}"

  worktree_prompt_file "SC-1 demo"
  run tmux_call_args "display-message"
  [[ "${output}" == *"=SC-1 demo:claude"* ]]
  [[ "${output}" == *"pane_current_path"* ]]
}
