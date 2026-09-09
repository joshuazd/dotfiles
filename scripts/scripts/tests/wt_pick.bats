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
  # Short client by default, so the tests written for the fzf picker keep
  # exercising it. The native-menu tests raise it explicitly.
  export TMUX_STUB_CLIENT_HEIGHT=4
  # bats has no terminal, so the fzf path would otherwise re-enter a popup
  # instead of running fzf. The popup re-entry has its own test below.
  export MENU_ASSUME_TTY=1
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
  [ "${status}" -eq 97 ]
  refute_cmd_called git-worktree-cleanup
}

# The gate is handed the cleanup as an action rather than asked for an answer:
# display-menu does not reliably block until its menu is answered, so a status
# read afterwards always said cancel and the removal never happened.
@test "the gate is handed the cleanup as its action" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  [ "${status}" -eq 0 ]
  run cmd_call_args wt-confirm
  [[ "${output}" == *"--run"* ]]
  [[ "${output}" == *"wt-pick --cleanup"* ]]
  [[ "${output}" == *"${WT_A}"* ]]
}

# Nothing destructive on the asking pass - only the gate's chosen item runs it.
@test "asking the gate cleans up nothing by itself" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  refute_cmd_called git-worktree-cleanup
  refute_tmux_subcommand display-popup
}

@test "--cleanup runs the cleanup on the given worktree" {
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  run "${WT_PICK}" --cleanup "${WT_A}"
  assert_cmd_called git-worktree-cleanup
  run cmd_call_args git-worktree-cleanup
  [ "${lines[1]}" = "${WT_A}" ]
}

# Removing a worktree is fire-and-forget: the session leaving vigil is the
# feedback. A popup here was tried and rejected - it was reasoned from
# "run-shell output is invisible behind an alternate screen", which is true and
# beside the point, and it left a modal to dismiss after every removal.
@test "--cleanup opens no popup" {
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  run "${WT_PICK}" --cleanup "${WT_A}"
  refute_tmux_subcommand display-popup
}

# Nothing may reach the cleanup without a path to clean up.
@test "--cleanup with no path is a usage error" {
  run "${WT_PICK}" --cleanup
  [ "${status}" -eq 2 ]
}

# The gate-before-cleanup ordering is no longer one assertion: the gate is
# handed the cleanup as a command rather than running it, so there is no
# second call to order against. "a cancelled gate cleans up nothing" and
# "asking the gate cleans up nothing by itself" pin the property between them.

@test "the gate is told which worktree is at stake" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" remove
  # The path is no longer the first argument: --run and its command come
  # first, so this checks the positional the gate actually describes.
  run cmd_call_args wt-confirm
  local pkg
  pkg="$(cd "$(dirname "${WT_PICK}")" && pwd)"
  printf '%s\n' "${output}" \
    | assert_arg_after "--run" "$(printf '%q' "${pkg}/wt-pick") --cleanup $(printf '%q' "${WT_A}")"
  [[ "${output}" == *"${WT_A}"* ]]
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
  [ "${status}" -eq 97 ]
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

@test "--act switch hands the path to ts without a picker" {
  stub_cmd ts
  run "${WT_PICK}" --act switch "${WT_A}"
  [ "${status}" -eq 0 ]
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
  refute_fzf_called
}

@test "--act remove goes through the gate" {
  stub_cmd wt-confirm "" 0
  stub_cmd git-worktree-cleanup
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  run "${WT_PICK}" --act remove "${WT_A}"
  [ "${status}" -eq 0 ]
  assert_cmd_called wt-confirm
  run cmd_call_args wt-confirm
  [[ "${output}" == *"wt-pick --cleanup"* ]]
}

@test "--act with an unknown verb is a usage error" {
  run "${WT_PICK}" --act frobnicate "${WT_A}"
  [ "${status}" -eq 2 ]
}

@test "--act with no value is a usage error" {
  run "${WT_PICK}" --act switch
  [ "${status}" -eq 2 ]
}

@test "the verb path renders a menu whose items call --act" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  stub_cmd ts
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  run tmux_call_args display-menu
  [[ "${output}" == *"--act switch"* ]]
  [[ "${output}" == *"wt-a"* ]]
}

@test "the verb path falls back to fzf on a short client" {
  export TMUX_STUB_CLIENT_HEIGHT=4
  stub_cmd ts
  export FZF_STUB_SELECTION="${WT_A}"$'\twt-a  feature-a'
  run "${WT_PICK}" switch
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-menu
  run cmd_call_args ts
  [ "${lines[1]}" = "${WT_A}" ]
}
