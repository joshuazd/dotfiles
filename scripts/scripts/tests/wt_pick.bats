#!/usr/bin/env bats

load helper

# Real git, not a stub: lib/git.sh and the worktree scripts lean on real git
# behavior, and `git worktree add` in a tmpdir is fast.
setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  WT_PICK="${BATS_TEST_DIRNAME}/../wt-pick"

  MAIN="${BATS_TEST_TMPDIR}/main"
  mkdir -p "${MAIN}"
  git -C "${MAIN}" init -q -b main
  git -C "${MAIN}" config user.email t@example.com
  git -C "${MAIN}" config user.name Test
  printf 'one\n' > "${MAIN}/file.txt"
  git -C "${MAIN}" add file.txt
  git -C "${MAIN}" commit -qm first

  WT_A="${BATS_TEST_TMPDIR}/wt-a"
  WT_B="${BATS_TEST_TMPDIR}/wt-b"
  git -C "${MAIN}" worktree add -q -b feature-a "${WT_A}"
  git -C "${MAIN}" worktree add -q -b feature-b "${WT_B}"

  cd "${MAIN}"
}

@test "switch hands the chosen directory to ts" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
}

@test "the main repository is not offered" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  run fzf_rows
  [[ "${output}" != *"${MAIN}"* ]]
  # Guard against the assertion above passing on an empty list.
  [[ "${output}" == *"${WT_A}"* ]]
}

@test "the current worktree is left out of the rows, not just unselected" {
  stub_cmd ts
  cd "${WT_A}"
  export FZF_STUB_SELECTION="${WT_B}"$'\twt-b  feature-b'
  run "${WT_PICK}" switch
  run fzf_rows
  [[ "${output}" != *"${WT_A}"* ]]
  [[ "${output}" == *"${WT_B}"* ]]
}

# Standing in a worktree rather than the main checkout is the only situation
# where the main-checkout exclusion is the thing doing the work: from the main
# checkout the current-directory exclusion already covers it, so a test run
# from there passes even with the main-checkout check deleted.
@test "the main repository is excluded even when it is not the current dir" {
  stub_cmd ts
  cd "${WT_A}"
  export FZF_STUB_SELECTION="${WT_B}"$'\twt-b  feature-b'
  run "${WT_PICK}" switch
  run fzf_rows
  [[ "${output}" != *"${MAIN}	"* ]]
  [[ "${output}" == *"${WT_B}"* ]]
}

@test "rows carry the branch name" {
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  run fzf_rows
  [[ "${output}" == *"feature-a"* ]]
  [[ "${output}" == *"feature-b"* ]]
}

@test "the current worktree is not offered" {
  stub_cmd ts
  cd "${WT_A}"
  export FZF_STUB_SELECTION="${WT_B}"$'\twt-b  feature-b'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_B}" ]
}

@test "remove asks the gate before cleaning up" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  assert_cmd_called wt-confirm
}

@test "a cancelled gate cleans up nothing" {
  stub_cmd wt-confirm "" 1
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  refute_cmd_called git-worktree-cleanup
}

@test "a confirmed removal cleans up the chosen worktree" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  assert_cmd_called git-worktree-cleanup
  run cmd_call_args git-worktree-cleanup
  [ "${lines[1]}" = "${WT_A}" ]
}

@test "the gate is asked before the cleanup, not after" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "$(cmd_call_index wt-confirm)" -lt "$(cmd_call_index git-worktree-cleanup)" ]
}

@test "the gate is told which worktree is at stake" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  run cmd_call_args wt-confirm
  [ "${lines[1]}" = "${WT_A}" ]
}

# Nothing may be destroyed by a gate that could not run.
@test "a missing gate cleans up nothing" {
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${BATS_TEST_TMPDIR}/empty-pkg"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -ne 0 ]
  refute_cmd_called git-worktree-cleanup
}

@test "escaping runs nothing" {
  stub_cmd ts
  export FZF_STUB_ABORT=1
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  refute_cmd_called ts
}

@test "an empty list says so and runs nothing" {
  stub_cmd ts
  git -C "${MAIN}" worktree remove --force "${WT_A}"
  git -C "${MAIN}" worktree remove --force "${WT_B}"
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No other worktrees."* ]]
  refute_cmd_called ts
}

@test "an unknown verb is a usage error" {
  run "${WT_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${WT_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${WT_PICK}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
