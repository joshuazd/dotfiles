#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  PR_PICK="${BATS_TEST_DIRNAME}/../pr-pick"
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  export VIGIL_BIN="${CMD_STUB_BIN}/vigil"
  URL41="https://github.com/org/repo/pull/41"
  URL42="https://github.com/org/repo/pull/42"
  # What `gh pr list --jq ...` produces: url, number, padded title, author.
  PR_LIST="$(printf '%s\t41\tFix the thing\talice\n%s\t42\tAdd the other\tbob' "${URL41}" "${URL42}")"
  # Short client by default, so the tests written for the fzf picker keep
  # exercising it. The native-menu tests raise it explicitly.
  export TMUX_STUB_CLIENT_HEIGHT=4
  # bats has no terminal, so the fzf path would otherwise re-enter a popup
  # instead of running fzf. The popup re-entry has its own test below.
  export MENU_ASSUME_TTY=1
}

@test "checkout hands the URL to gh-worktree" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  run cmd_call_args gh-worktree
  [ "${lines[1]}" = "${URL41}" ]
}

@test "review dispatches the URL to vigil instead of running gh-review" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd vigil "dispatch queued: ${URL42}"
  stub_cmd gh-review
  export FZF_STUB_SELECTION="${URL42}"$'\t#42  Add the other  bob'
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  run cmd_call_args vigil
  [ "${lines[1]}" = "dispatch" ]
  printf '%s\n' "${output}" | assert_arg_after "--cwd" "${PWD}"
  [ "${lines[${#lines[@]}-1]}" = "${URL42}" ]
  refute_cmd_called gh-review
}

# A native menu item runs under `run-shell -b`, which writes stdout into the
# focused pane.
@test "review keeps vigil's success line out of the pane" {
  stub_cmd vigil "dispatch queued: ${URL42}"
  run "${PR_PICK}" --act review "${URL42}"
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"dispatch queued"* ]]
}

@test "review surfaces a refused dispatch" {
  stub_cmd vigil "" 1
  run "${PR_PICK}" --act review "${URL42}"
  [ "${status}" -ne 0 ]
}

@test "review with no vigil installed says so" {
  export VIGIL_BIN=""
  export PATH="/usr/bin:/bin"
  export HOME="${BATS_TEST_TMPDIR}"
  run "${PR_PICK}" --act review "${URL42}"
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"vigil not found"* ]]
}

@test "browse opens the PR in a browser" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" browse
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"--web"* ]]
  [[ "${output}" == *"${URL41}"* ]]
}

@test "diff shows the PR diff" {
  stub_cmd gh "${PR_LIST}"
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" diff
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"diff"* ]]
}

# The rows arrive on stdin, so this has to read fzf_rows, not fzf_args.
@test "rows carry the number, title and author" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" checkout
  run fzf_rows
  [[ "${output}" == *"#41"* ]]
  [[ "${output}" == *"Fix the thing"* ]]
  [[ "${output}" == *"alice"* ]]
}

@test "the URL is hidden and the summary is displayed" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" checkout
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "gh is handed lib/pr-rows.jq as its filter" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" checkout
  run cmd_call_args gh
  printf '%s\n' "${output}" \
    | assert_arg_after "--jq" "$(head -1 "${BATS_TEST_DIRNAME}/../lib/pr-rows.jq")"
}

# The gh stub emits finished rows, so the filter is otherwise never run.
@test "the jq filter strips story tags, truncates long titles and aligns authors" {
  command -v jq >/dev/null || skip "jq not installed"
  local filter="${BATS_TEST_DIRNAME}/../lib/pr-rows.jq"
  local long
  long="$(printf 'x%.0s' $(seq 1 90))"
  local json='[
    {"url":"u1","number":1,"title":"Short [sc-123]","author":{"login":"alice"}},
    {"url":"u2","number":2,"title":"sc-456 Leading tag","author":{"login":"bob"}},
    {"url":"u3","number":3,"title":"'"${long}"'","author":{"login":"carol"}}
  ]'
  run jq -r -f "${filter}" <<< "${json}"
  [ "${status}" -eq 0 ]
  local titles=()
  local u n t a
  while IFS=$'\t' read -r u n t a; do titles+=("${t}"); done <<< "${output}"
  [[ "${titles[0]}" == "Short "* ]]
  [[ "${titles[0]}" != *"sc-"* ]]
  [[ "${titles[1]}" == "Leading tag "* ]]
  [[ "${titles[2]}" == *"…" ]]
  [ "$(printf '%s' "${titles[0]}" | wc -m)" -eq "$(printf '%s' "${titles[2]}" | wc -m)" ]
}

@test "lists only PRs requesting my review" {
  stub_cmd gh "${PR_LIST}"
  stub_cmd gh-worktree
  export FZF_STUB_SELECTION="${URL41}"$'\t#41  Fix the thing  alice'
  run "${PR_PICK}" checkout
  run cmd_call_args gh
  printf '%s\n' "${output}" | assert_arg_after "--search" "review-requested:@me"
}

@test "an empty list says so and runs nothing" {
  stub_cmd gh ""
  stub_cmd gh-worktree
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No PRs awaiting review."* ]]
  refute_cmd_called gh-worktree
}

# gh fails when there is no network, no auth, or no repo. None of those should
# surface as a stack of diagnostics in a popup.
@test "a failing gh reads as an empty list, not an error" {
  stub_cmd gh "" 1
  stub_cmd gh-worktree
  run "${PR_PICK}" checkout
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No PRs awaiting review."* ]]
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

@test "--act review resolves a bare number to its URL for vigil" {
  stub_cmd gh "${URL42}"
  stub_cmd vigil
  run "${PR_PICK}" --act review 42
  [ "${status}" -eq 0 ]
  run cmd_call_args vigil
  [ "${lines[${#lines[@]}-1]}" = "${URL42}" ]
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
  stub_cmd vigil
  run "${PR_PICK}" review
  run tmux_call_args display-menu
  [[ "${output}" == *"--act review"* ]]
  [[ "${output}" == *"${URL41}"* ]]
}

# The case that motivates the fallback: more PRs than the terminal is tall.
@test "a long PR list falls back to fzf rather than blanking" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  local rows="" i
  for i in $(seq 1 40); do
    rows="${rows}https://github.com/org/repo/pull/${i}"$'\t'"${i}"$'\t'"PR ${i}"$'\t'"author-${i}"$'\n'
  done
  stub_cmd gh "${rows}"
  stub_cmd vigil
  export FZF_STUB_SELECTION=$'https://github.com/org/repo/pull/7\t#7  PR 7  author-7'
  run "${PR_PICK}" review
  [ "${status}" -eq 0 ]
  refute_tmux_subcommand display-menu
  run cmd_call_args vigil
  [ "${lines[${#lines[@]}-1]}" = "https://github.com/org/repo/pull/7" ]
}

# Without a terminal there is nothing for fzf to draw on, so the picker has to
# re-enter inside a popup rather than silently doing nothing. Getting this
# wrong is what made "Review PR" open an empty box.
@test "the fzf path re-enters a popup when there is no terminal" {
  unset MENU_ASSUME_TTY
  export TMUX_STUB_CLIENT_HEIGHT=10
  local rows="" i
  for i in $(seq 1 40); do
    rows="${rows}https://github.com/org/repo/pull/${i}"$'\t'"${i}"$'\t'"PR ${i}"$'\t'"author-${i}"$'\n'
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
