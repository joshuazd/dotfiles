#!/usr/bin/env bats

load helper

# The worktree scripts are recorders here: the real ones would create a
# worktree and a tmux session, and what these tests are about is the branch
# name that reaches them.
setup() {
  setup_tmux_stub
  setup_cmd_stubs
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  stub_cmd git-worktree-new
  stub_cmd git-worktree-session
  WT_NEW="${BATS_TEST_DIRNAME}/../wt-new"
  MENU_DIR="${BATS_TEST_DIRNAME}/../menus"

  REPO="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${REPO}"
  git -C "${REPO}" init -q -b main
  cd "${REPO}"
}

# bats has no terminal, so the read path has to be reached the way a script
# would: no tty and no tmux client. With TMUX set, the same input takes the
# status-bar path instead, which is what the tests below assert.
pipe_answer() {
  local answer="${1}"
  shift
  printf '%s\n' "${answer}" | env -u TMUX "${WT_NEW}" ${1+"${@}"}
}

@test "a branch name given on the command line goes straight through" {
  run "${WT_NEW}" feature/add-login
  [ "${status}" -eq 0 ]
  run cmd_call_args git-worktree-new
  [ "${lines[1]}" = "feature/add-login" ]
}

@test "with no argument it asks, and creates what was typed" {
  run pipe_answer feature/from-prompt
  [ "${status}" -eq 0 ]
  run cmd_call_args git-worktree-new
  [ "${lines[1]}" = "feature/from-prompt" ]
}

# The bug this whole script exists for: the menu used to run git-worktree-new
# with no arguments at all, which exits 1 on the missing branch name and takes
# its @window tmux window down with it before the error can be read.
@test "an empty answer creates nothing" {
  run pipe_answer ""
  refute_cmd_called git-worktree-new
}

@test "an empty answer closes the popup without a pause" {
  run pipe_answer ""
  [ "${status}" -eq 97 ]
}

@test "a whitespace-only answer creates nothing" {
  run pipe_answer "   "
  refute_cmd_called git-worktree-new
  [ "${status}" -eq 97 ]
}

@test "a closed input creates nothing" {
  run env -u TMUX "${WT_NEW}" < /dev/null
  refute_cmd_called git-worktree-new
  [ "${status}" -eq 97 ]
}

# A menu front end takes a branch name and nothing else. git-worktree-new's
# own flags stay on git-worktree-new, which a caller that wants them is
# already invoking directly.
@test "a second argument is a usage error, not a silently ignored one" {
  run "${WT_NEW}" feature/add-login extra
  [ "${status}" -eq 2 ]
  refute_cmd_called git-worktree-new
}

@test "an unknown option is a usage error" {
  run "${WT_NEW}" --prefix
  [ "${status}" -eq 2 ]
  refute_cmd_called git-worktree-new
}

@test "it refuses outside a git repository" {
  cd "${BATS_TEST_TMPDIR}"
  run "${WT_NEW}" feature/add-login
  [ "${status}" -ne 0 ]
  refute_cmd_called git-worktree-new
}

@test "--help prints usage without creating anything" {
  run "${WT_NEW}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
  refute_cmd_called git-worktree-new
}

@test "--session creates the session detached and switches to it" {
  run "${WT_NEW}" --session feature/add-login
  [ "${status}" -eq 0 ]
  run cmd_call_args git-worktree-session
  [ "${lines[1]}" = "--detached" ]
  [ "${lines[2]}" = "feature/add-login" ]
  refute_cmd_called git-worktree-new
  run tmux_call_args switch-client
  assert_arg_after -t "=add-login" <<< "${output}"
}

@test "--session asks for the branch name too" {
  run pipe_answer feature/from-prompt --session
  [ "${status}" -eq 0 ]
  run cmd_call_args git-worktree-session
  [ "${lines[2]}" = "feature/from-prompt" ]
}

@test "--session with an empty answer creates nothing" {
  run pipe_answer "" --session
  [ "${status}" -eq 97 ]
  refute_cmd_called git-worktree-session
  refute_tmux_subcommand switch-client
}

# SESSION_EXISTED is the session already being there, which is not a failure
# and must not be reported as one - the switch is still what the user asked
# for.
@test "--session switches to a session that already existed" {
  stub_cmd git-worktree-session "" 3
  run "${WT_NEW}" --session feature/add-login
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand switch-client
}

@test "--session does not switch when the session could not be created" {
  stub_cmd git-worktree-session "" 1
  run "${WT_NEW}" --session feature/add-login
  [ "${status}" -eq 1 ]
  refute_tmux_subcommand switch-client
}

# The prompt's size is the whole point of the status-bar path: a bare menu
# entry would ask inside fzf-menu's 80%x60% output popup.
@test "with a tmux client and no tty it asks on the status bar" {
  run "${WT_NEW}"
  [ "${status}" -eq 0 ]
  assert_tmux_subcommand command-prompt
  refute_tmux_subcommand display-popup
  refute_cmd_called git-worktree-new
}

@test "the status-bar prompt hands the answer to --act" {
  run "${WT_NEW}"
  run tmux_call_args command-prompt
  [[ "${output}" == *"wt-new --act"* ]]
  [[ "${output}" == *"run-shell -b"* ]]
}

@test "the status-bar prompt carries --session through to --act" {
  run "${WT_NEW}" --session
  run tmux_call_args command-prompt
  [[ "${output}" == *"--act --session"* ]]
}

# The answer travels in a tmux option, not in the run-shell command's text:
# command-prompt substitutes %% before anything parses it, so a name in that
# string would be read by the shell with no way to escape it from here.
@test "the answer is parked in an option rather than interpolated into a command" {
  run "${WT_NEW}"
  run tmux_call_args command-prompt
  [[ "${output}" == *"set-option -g @wt_new_branch '%%'"* ]]
  [[ "${output}" != *"--act"*"%%"* ]]
}

# The repository is resolved while the prompt is opened, not when the answer
# arrives: by then the focused pane is whatever the user is looking at.
@test "--act is told which repository to create in" {
  run "${WT_NEW}"
  run tmux_call_args command-prompt
  [[ "${output}" == *"${REPO}"* ]]
}

@test "--act creates what the prompt parked, in a popup" {
  export TMUX_STUB_WT_NEW_BRANCH="feature/from-status-bar"
  run "${WT_NEW}" --act "${REPO}"
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  [[ "${output}" == *"feature/from-status-bar"* ]]
  [[ "${output}" == *"git-worktree-new"* ]]
}

@test "--act clears the parked answer" {
  export TMUX_STUB_WT_NEW_BRANCH="feature/from-status-bar"
  run "${WT_NEW}" --act "${REPO}"
  run tmux_call_args_matching set-option "@wt_new_branch"
  [[ "${output}" == *"-gu"* ]]
}

@test "--act with nothing parked creates nothing" {
  export TMUX_STUB_WT_NEW_BRANCH=""
  run "${WT_NEW}" --act "${REPO}"
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-popup
  refute_cmd_called git-worktree-new
}

@test "--act --session creates the session in a popup and switches after" {
  export TMUX_STUB_WT_NEW_BRANCH="feature/from-status-bar"
  run "${WT_NEW}" --act --session "${REPO}"
  [ "${status}" -eq 0 ]
  run tmux_call_args display-popup
  [[ "${output}" == *"git-worktree-session"* ]]
  [[ "${output}" == *"--detached"* ]]
  run tmux_call_args switch-client
  assert_arg_after -t "=from-status-bar" <<< "${output}"
}

@test "--act without a repository is a usage error" {
  run "${WT_NEW}" --act
  [ "${status}" -eq 2 ]
  refute_tmux_subcommand display-popup
}

# The menu rows are the thing that was broken. An entry that names
# git-worktree-new or git-worktree-session directly has no branch name to give
# it, and a bare entry would ask inside the output popup.
@test "the worktree menu reaches the worktree scripts through wt-new" {
  local rows
  rows="$(grep '	' "${MENU_DIR}/worktree.menu")"
  [[ "${rows}" == *"@quiet wt-new --session"* ]]
  [[ "${rows}" == *"@quiet wt-new"* ]]
  [[ "${rows}" != *"git-worktree-new"* ]]
  [[ "${rows}" != *"git-worktree-session"* ]]
}

@test "both new-worktree rows run @quiet" {
  local row command checked=0
  while IFS= read -r row; do
    case "${row}" in '#'*) continue ;; esac
    command="${row#*$'\t'}"
    case "${command}" in
      *wt-new*)
        [[ "${command}" == '@quiet wt-new'* ]]
        checked=$((checked + 1))
        ;;
    esac
  done < "${MENU_DIR}/worktree.menu"
  # Both rows, or the loop checked nothing and passed for it.
  [ "${checked}" -eq 2 ]
}
