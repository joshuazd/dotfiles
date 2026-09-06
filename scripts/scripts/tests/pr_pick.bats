#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  PR_PICK="${BATS_TEST_DIRNAME}/../pr-pick"
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  # What `gh pr list --jq ...` produces: number, title, branch.
  PR_LIST="$(printf '41\tFix the thing\tfix-thing\n42\tAdd the other\tadd-other')"
}

@test "checkout hands the number to gh-worktree" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-worktree
  [ "${lines[1]}" = "41" ]
}

@test "review hands the number to gh-review" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-review
  export FZF_STUB_SELECTION=$'42\t#42  Add the other  [add-other]'
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-review
  [ "${lines[1]}" = "42" ]
}

@test "browse opens the PR in a browser" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" browse
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"--web"* ]]
  [[ "${output}" == *"41"* ]]
}

@test "diff shows the PR diff" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" diff
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"diff"* ]]
}

# The rows arrive on stdin, so this has to read fzf_rows, not fzf_args.
@test "rows carry the number, title and branch" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" checkout
  run fzf_rows
  [[ "${output}" == *"#41"* ]]
  [[ "${output}" == *"Fix the thing"* ]]
  [[ "${output}" == *"fix-thing"* ]]
}

@test "the number is hidden and the summary is displayed" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION=$'41\t#41  Fix the thing  [fix-thing]'
  run "${PR_PICK}" checkout
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "an empty list says so and runs nothing" {
  stub_cmd gh ""
  stub_cmd gh-worktree
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No open PRs."* ]]
  refute_cmd_called gh-worktree
}

# gh fails when there is no network, no auth, or no repo. None of those should
# surface as a stack of diagnostics in a popup.
@test "a failing gh reads as an empty list, not an error" {
  stub_cmd gh "" 1
  stub_cmd gh-worktree
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No open PRs."* ]]
  refute_cmd_called gh-worktree
}

@test "escaping runs nothing" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_ABORT=1
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  refute_cmd_called gh-worktree
}

@test "an unknown verb is a usage error" {
  run "${PR_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${PR_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${PR_PICK}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
