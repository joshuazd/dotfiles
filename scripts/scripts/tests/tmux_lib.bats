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

@test "launch_claude_in_pane targets the marked pane by id" {
  export TMUX_STUB_LIST_PANES="%4 0
%5 1"
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"%5"* ]]
  [[ "${output}" != *":claude.1"* ]]
}

@test "launch_claude_in_pane falls back to the positional target for older sessions" {
  export TMUX_STUB_LIST_PANES=""
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
}

@test "setup_secondary_pane sends its command to the pane it just made" {
  export TMUX_STUB_DISPLAY="120"
  export TMUX_STUB_SPLIT_PANE="%8"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "send-keys"
  [[ "${output}" == *"%8"* ]]
  [[ "${output}" != *":claude.2"* ]]
}

@test "setup_secondary_pane returns focus to the claude pane by id" {
  export TMUX_STUB_DISPLAY="120"
  export TMUX_STUB_LIST_PANES="%4 1"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "select-pane"
  [[ "${output}" == *"%4"* ]]
}

@test "create_tmux_session marks the claude pane" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_calls
  [[ "${output}" == *"@vigil_claude"* ]]
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

@test "create_tmux_session leaves an existing session's claude alone" {
  export TMUX_STUB_HAS_SESSION=0
  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand "new-session"
  [ "${status}" -eq 0 ]
}

# A stand-in for git-worktree-session that exits with the status given as $1,
# so run_worktree_popup's handling of it can be exercised without a worktree.
_fake_session_script() {
  local exit_status="${1}"
  local script="${BATS_TEST_TMPDIR}/fake-session-script"
  printf '#!/usr/bin/env bash\nexit %s\n' "${exit_status}" > "${script}"
  chmod +x "${script}"
  printf '%s' "${script}"
}

@test "run_worktree_popup carries SESSION_EXISTED out of the popup" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --detached --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
}

@test "run_worktree_popup keeps the status through the interactive prompt" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --detached \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo" < /dev/null
  [ "${status}" -eq "${SESSION_EXISTED}" ]
}

@test "run_worktree_popup still switches to a session that already existed" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
  run assert_tmux_subcommand "switch-client"
  [ "${status}" -eq 0 ]
}

@test "run_worktree_popup reports a failing popup and does not switch" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script 1)"

  run run_worktree_popup --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq 1 ]
  run refute_tmux_subcommand "switch-client"
  [ "${status}" -eq 0 ]
}

# Drives git-worktree-session itself rather than a stand-in, so the real
# ordering is exercised: git-worktree-new runs before create_tmux_session and
# hard-fails on an existing directory, which on a re-dispatch would mask
# SESSION_EXISTED behind a generic failure and never tell the caller to leave
# the running Claude alone. The worktree directory is pre-created here because
# that is what a re-dispatch actually looks like.
@test "git-worktree-session reports SESSION_EXISTED without creating a worktree" {
  export TMUX_STUB_HAS_SESSION=0

  local repo="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${repo}" "${BATS_TEST_TMPDIR}/wt"
  git -C "${repo}" init --quiet

  cd "${repo}"
  run "${BATS_TEST_DIRNAME}/../git-worktree-session" \
    --detached --dir-name wt --session-name "SC-1 demo" feature/x

  [ "${status}" -eq "${SESSION_EXISTED}" ]
  [[ "${output}" != *"Creating worktree"* ]]
  [[ "${output}" != *"Failed to create worktree"* ]]
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand "new-session"
  [ "${status}" -eq 0 ]
}

@test "git-worktree-session still creates a worktree when only the directory exists" {
  export TMUX_STUB_HAS_SESSION=1

  local repo="${BATS_TEST_TMPDIR}/repo2"
  mkdir -p "${repo}" "${BATS_TEST_TMPDIR}/wt2"
  git -C "${repo}" init --quiet

  cd "${repo}"
  run "${BATS_TEST_DIRNAME}/../git-worktree-session" \
    --detached --dir-name wt2 --session-name "SC-2 demo" feature/y

  [ "${status}" -ne 0 ]
  [ "${status}" -ne "${SESSION_EXISTED}" ]
  [[ "${output}" == *"Creating worktree"* ]]
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
