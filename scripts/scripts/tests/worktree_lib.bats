#!/usr/bin/env bats

load helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/worktree.sh"
  REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q
  git -C "${REPO}" config user.email t@example.com
  git -C "${REPO}" config user.name Test
  printf 'one\n' > "${REPO}/file.txt"
  git -C "${REPO}" add file.txt
  git -C "${REPO}" commit -qm first
}

# Give the repo an upstream, so the unpushed count has something to measure
# against. Without one worktree_unpushed_count correctly returns nothing.
push_to_new_remote() {
  local remote="${BATS_TEST_TMPDIR}/remote.git"
  git init -q --bare "${remote}"
  git -C "${REPO}" remote add origin "${remote}"
  git -C "${REPO}" push -q -u origin HEAD
}

@test "a clean worktree has no dirty files" {
  [ "$(worktree_dirty_count "${REPO}")" -eq 0 ]
}

@test "dirty files are counted" {
  printf 'two\n' > "${REPO}/file.txt"
  printf 'new\n' > "${REPO}/other.txt"
  [ "$(worktree_dirty_count "${REPO}")" -eq 2 ]
}

@test "a directory that is not a repo counts as clean" {
  mkdir -p "${BATS_TEST_TMPDIR}/plain"
  [ "$(worktree_dirty_count "${BATS_TEST_TMPDIR}/plain")" -eq 0 ]
}

@test "no upstream means no unpushed count" {
  [ -z "$(worktree_unpushed_count "${REPO}")" ]
}

@test "unpushed commits are counted against the upstream" {
  push_to_new_remote
  printf 'three\n' > "${REPO}/file.txt"
  git -C "${REPO}" commit -qam second
  [ "$(worktree_unpushed_count "${REPO}")" -eq 1 ]
}

@test "a clean pushed worktree summarises as clean" {
  push_to_new_remote
  [ "$(worktree_risk_summary "${REPO}")" = "clean" ]
}

@test "the summary names both counts" {
  push_to_new_remote
  printf 'three\n' > "${REPO}/file.txt"
  git -C "${REPO}" commit -qam second
  printf 'dirty\n' > "${REPO}/scratch.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" == *"1 uncommitted file"* ]]
  [[ "${output}" == *"1 unpushed commit"* ]]
}

@test "the summary is plural for more than one" {
  printf 'a\n' > "${REPO}/a.txt"
  printf 'b\n' > "${REPO}/b.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" == *"2 uncommitted files"* ]]
}

@test "the summary omits the unpushed clause when there is no upstream" {
  printf 'a\n' > "${REPO}/a.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" != *"unpushed"* ]]
}

# A worktree that is pushed but dirty, and one that is clean but unpushed,
# must each name only the clause that applies.
@test "the summary omits the clean clause on either side" {
  push_to_new_remote
  printf 'a\n' > "${REPO}/a.txt"
  run worktree_risk_summary "${REPO}"
  [[ "${output}" == *"uncommitted"* ]]
  [[ "${output}" != *"unpushed"* ]]
}

# --- worktree_run_cleanup -------------------------------------------------
#
# Both callers run under `run-shell -b`, whose stdout tmux writes into the
# focused pane - which after prefix d is a pane in some other session. A popup
# was the previous answer and was worse.

@test "the cleanup's output does not reach stdout" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\necho noisy-output\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" run worktree_run_cleanup "${script}"
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"noisy-output"* ]]
}

@test "the cleanup's output lands in the log" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\necho noisy-output\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" worktree_run_cleanup "${script}"
  grep -q 'noisy-output' "${LOG}"
}

# A refusal is the one thing anyone would ever go looking for.
@test "a failing cleanup records its complaint" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\necho "cannot remove: dirty" >&2\nexit 1\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" run worktree_run_cleanup "${script}"
  [ "${status}" -eq 1 ]
  grep -q 'cannot remove: dirty' "${LOG}"
}

@test "the cleanup is passed its arguments" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\nprintf "[%%s]" "$@"\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" worktree_run_cleanup "${script}" --session s "/tmp/a b"
  grep -q '\[--session\]\[s\]\[/tmp/a b\]' \
    "${LOG}"
}

# Appended, not truncated: the previous removal's complaint is often the one
# worth reading.
@test "the log accumulates across removals" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\necho "run $1"\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" worktree_run_cleanup "${script}" one
  WORKTREE_CLEANUP_LOG="${LOG}" worktree_run_cleanup "${script}" two
  grep -q 'run one' "${LOG}"
  grep -q 'run two' "${LOG}"
}

@test "each entry says which worktree it was" {
  local LOG="${BATS_TEST_TMPDIR}/cleanup.log"
  local script="${BATS_TEST_TMPDIR}/fake-cleanup"
  printf '#!/bin/sh\nexit 0\n' > "${script}"
  chmod +x "${script}"
  WORKTREE_CLEANUP_LOG="${LOG}" worktree_run_cleanup "${script}" /tmp/some-worktree
  grep -q '^=== .*/tmp/some-worktree' \
    "${LOG}"
}
