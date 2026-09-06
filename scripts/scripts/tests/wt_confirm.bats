#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  WT_CONFIRM="${BATS_TEST_DIRNAME}/../wt-confirm"
  REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q
  git -C "${REPO}" config user.email t@example.com
  git -C "${REPO}" config user.name Test
  printf 'one\n' > "${REPO}/file.txt"
  git -C "${REPO}" add file.txt
  git -C "${REPO}" commit -qm first
}

@test "picking Remove exits 0" {
  export FZF_STUB_SELECTION=$'confirm\t2 Remove worktree and kill session'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 0 ]
}

@test "picking Cancel exits 1" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 1 ]
}

@test "escaping exits 1" {
  export FZF_STUB_ABORT=1
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 1 ]
}

# Cancel is offered first so it is where the cursor starts and what Enter
# answers. A destructive default is the whole bug this script exists to fix.
# With no forced selection the stub returns the first row it was handed, which
# is exactly the Enter-key behavior under test.
@test "Enter on an unmoved cursor cancels" {
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  [ "${status}" -eq 1 ]
}

@test "the prompt names the session" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"repo-session"* ]]
}

@test "the header names the path" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"${REPO}"* ]]
}

@test "the header reports uncommitted work" {
  printf 'dirty\n' > "${REPO}/scratch.txt"
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"1 uncommitted file"* ]]
}

@test "the header says clean when nothing is at risk" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  run fzf_args
  [[ "${output}" == *"clean"* ]]
}

@test "--inline never opens a popup" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}" repo-session
  refute_tmux_subcommand display-popup
}

# Without a tty there is nothing to prompt on, so the gate has to build its
# own popup and re-enter itself inside it.
@test "with no tty the gate opens a popup and re-enters itself" {
  run "${WT_CONFIRM}" "${REPO}" repo-session < /dev/null
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"--inline"* ]]
  [[ "${output}" == *"--answer-file"* ]]
}

@test "a popup that never wrote an answer is a cancel" {
  # The tmux stub records display-popup without running it, so the answer file
  # stays empty - which is exactly the popup-died case.
  run "${WT_CONFIRM}" "${REPO}" repo-session < /dev/null
  [ "${status}" -eq 1 ]
}

@test "the popup pass reports confirm from the answer file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  printf 'confirm' > "${ANSWER}"
  run "${WT_CONFIRM}" --read-answer "${ANSWER}"
  [ "${status}" -eq 0 ]
}

@test "the popup pass reports cancel from the answer file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  printf 'cancel' > "${ANSWER}"
  run "${WT_CONFIRM}" --read-answer "${ANSWER}"
  [ "${status}" -eq 1 ]
}

@test "a missing answer file is a cancel" {
  run "${WT_CONFIRM}" --read-answer "${BATS_TEST_TMPDIR}/nope"
  [ "${status}" -eq 1 ]
}

@test "--inline writes confirm to the answer file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  export FZF_STUB_SELECTION=$'confirm\t2 Remove worktree and kill session'
  run "${WT_CONFIRM}" --inline --answer-file "${ANSWER}" "${REPO}" repo-session
  [ "$(cat "${ANSWER}")" = "confirm" ]
}

@test "--inline writes cancel to the answer file" {
  ANSWER="${BATS_TEST_TMPDIR}/answer"
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline --answer-file "${ANSWER}" "${REPO}" repo-session
  [ "$(cat "${ANSWER}")" = "cancel" ]
}

@test "the session defaults to the directory basename" {
  export FZF_STUB_SELECTION=$'cancel\t1 Cancel'
  run "${WT_CONFIRM}" --inline "${REPO}"
  run fzf_args
  [[ "${output}" == *"repo"* ]]
}

@test "a missing worktree argument is a usage error" {
  run "${WT_CONFIRM}" --inline
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

# The popup starts in the client pane's directory, not the caller's, so a
# relative invocation path would not resolve inside it and the popup would die
# before drawing - which the answer-file protocol reads as a cancel.
@test "the popup re-enters by absolute path even when invoked relatively" {
  cd "$(dirname "${WT_CONFIRM}")"
  run ./wt-confirm "${REPO}" repo-session < /dev/null
  run tmux_call_args display-popup
  [[ "${output}" == */wt-confirm* ]]
  [[ "${output}" != *"./wt-confirm"* ]]
}
