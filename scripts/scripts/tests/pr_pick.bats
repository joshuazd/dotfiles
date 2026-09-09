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
  # Short client by default, so the tests written for the fzf picker keep
  # exercising it. The native-menu tests raise it explicitly.
  export TMUX_STUB_CLIENT_HEIGHT=4
  # bats has no terminal, so the fzf path would otherwise re-enter a popup
  # instead of running fzf. The popup re-entry has its own test below.
  export MENU_ASSUME_TTY=1
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
  [ "${status}" -eq 97 ]
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

@test "--act review hands the number to gh-review without a picker" {
  stub_cmd gh-review
  run "${PR_PICK}" --act review 42
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-review
  [ "${lines[1]}" = "42" ]
  refute_fzf_called
}

@test "--act checkout hands the number to gh-worktree" {
  stub_cmd gh-worktree
  run "${PR_PICK}" --act checkout 41
  run cmd_call_args gh-worktree
  [ "${lines[1]}" = "41" ]
}

@test "--act with an unknown verb is a usage error" {
  run "${PR_PICK}" --act frobnicate 41
  [ "${status}" -eq 2 ]
}

@test "--act with no value is a usage error" {
  run "${PR_PICK}" --act review
  [ "${status}" -eq 2 ]
}

@test "the verb path renders a menu whose items call --act" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-review
  run "${PR_PICK}" review
  run tmux_call_args display-menu
  [[ "${output}" == *"--act review"* ]]
  [[ "${output}" == *"41"* ]]
}

# The case that motivates the fallback: more PRs than the terminal is tall.
@test "a long PR list falls back to fzf rather than blanking" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  local rows="" i
  for i in $(seq 1 40); do
    rows="${rows}${i}"$'\t'"PR ${i}"$'\t'"branch-${i}"$'\n'
  done
  stub_cmd gh "${rows}"
  stub_cmd gh-review
  export FZF_STUB_SELECTION=$'7\t#7  PR 7  [branch-7]'
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-menu
  run cmd_call_args gh-review
  [ "${lines[1]}" = "7" ]
}

# Without a terminal there is nothing for fzf to draw on, so the picker has to
# re-enter inside a popup rather than silently doing nothing. Getting this
# wrong is what made "Review PR" open an empty box.
@test "the fzf path re-enters a popup when there is no terminal" {
  unset MENU_ASSUME_TTY
  export TMUX_STUB_CLIENT_HEIGHT=10
  local rows="" i
  for i in $(seq 1 40); do
    rows="${rows}${i}"$'\t'"PR ${i}"$'\t'"branch-${i}"$'\n'
  done
  stub_cmd gh "${rows}"
  run "${PR_PICK}" review
  assert_tmux_subcommand display-popup
  run tmux_call_args display-popup
  [[ "${output}" == *"pr-pick"* ]]
  [[ "${output}" == *"review"* ]]
}

# A list that fits needs no popup and no terminal: the native menu is drawn by
# tmux itself, which is the whole reason @quiet entries work under run-shell.
@test "a fitting list needs no popup even without a terminal" {
  unset MENU_ASSUME_TTY
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_cmd gh "${PR_LIST}"
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand display-menu
  refute_tmux_subcommand display-popup
}
