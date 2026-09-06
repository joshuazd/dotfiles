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
