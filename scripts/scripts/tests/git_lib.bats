#!/usr/bin/env bats

load helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/git.sh"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}"
}

@test "pr_repo_dir resolves a PR URL to that repo's clone" {
  mkdir -p "${HOME}/soc-workflows"
  cd "${HOME}"

  run pr_repo_dir "https://github.com/huntresslabs/soc-workflows/pull/205"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${HOME}/soc-workflows" ]
}

# The whole defect: the working directory is a portal worktree and the PR is
# not portal's. Answering with the cwd cuts the review worktree from the wrong
# repository, where the PR's branch does not exist.
@test "pr_repo_dir prefers the URL's repo over the working directory" {
  mkdir -p "${HOME}/portal/wt" "${HOME}/soc-workflows"
  cd "${HOME}/portal/wt"

  run pr_repo_dir "https://github.com/huntresslabs/soc-workflows/pull/205"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${HOME}/soc-workflows" ]
}

# Fails loudly rather than falling back to the cwd: a silent fallback is
# exactly the bug this function exists to fix.
@test "pr_repo_dir fails when the URL's repo has no clone" {
  mkdir -p "${HOME}/portal"
  cd "${HOME}/portal"

  run pr_repo_dir "https://github.com/huntresslabs/sigma/pull/7"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"sigma"* ]]
  [[ "${output}" != *"${HOME}/portal"* ]]
}

# A bare number names no repository, so `gh pr view 123` already resolves
# against the caller's repo and the cwd is the only correct answer.
@test "pr_repo_dir answers with the working directory for a bare PR number" {
  mkdir -p "${HOME}/portal"
  cd "${HOME}/portal"

  run pr_repo_dir "123"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${HOME}/portal" ]
}

@test "pr_repo_dir accepts a PR URL with a trailing path" {
  mkdir -p "${HOME}/infra-k8s"
  cd "${HOME}"

  run pr_repo_dir "https://github.com/huntresslabs/infra-k8s/pull/12/files"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${HOME}/infra-k8s" ]
}
