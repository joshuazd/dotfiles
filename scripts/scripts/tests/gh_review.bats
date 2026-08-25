#!/usr/bin/env bats

load helper

# gh-review is driven end to end here rather than through a helper, because the
# defect was never in a helper: every piece of information needed to pick the
# right repository was already in the script and the popup was still told to cd
# into whatever directory the caller happened to be in. Only the call sites
# prove that is fixed.
#
# tmux, gh and claude are stubs; git-worktree-session is never reached, because
# the shared tmux stub records `display-popup` and returns 0 without running the
# command it was given. That command string is the assertion target.
setup() {
  setup_tmux_stub
  export GH_STUB_LOG="${BATS_TEST_TMPDIR}/gh-calls.log"
  : > "${GH_STUB_LOG}"

  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"

  # Keyed on the requested --json field list: gh-review asks for the branch and
  # title, the classifier asks for the body and files. One canned answer for
  # both would let a test pass while the classifier was fed the wrong PR.
  cat > "${BATS_TEST_TMPDIR}/bin/gh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "${*}" >> "${GH_STUB_LOG}"
case "${*}" in
  *headRefName,title,number*)
    printf '{"headRefName":"feature/x","title":"A review","number":205}\n'
    ;;
  *title,body,files*)
    printf '{"title":"A review","body":"","files":[],"labels":[],"headRefName":"feature/x"}\n'
    ;;
esac
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/gh"

  # The classifier must never reach the real API from a test. Failing is a
  # supported path: classify_pr warns and falls back to its default route.
  printf '#!/usr/bin/env bash\nexit 1\n' > "${BATS_TEST_TMPDIR}/bin/claude"
  chmod +x "${BATS_TEST_TMPDIR}/bin/claude"

  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}/portal/wt" "${HOME}/soc-workflows"
}

gh_review() {
  "${BATS_TEST_DIRNAME}/../gh-review" "${@}"
}

popup_command() {
  tmux_call_args "display-popup" | tail -1
}

@test "gh-review cuts the worktree from the repo named by the PR URL" {
  cd "${HOME}/portal/wt"

  run gh_review --detached --non-interactive --tier sonnet \
    "https://github.com/huntresslabs/soc-workflows/pull/205"
  [ "${status}" -eq 0 ]

  run popup_command
  [[ "${output}" == *"cd ${HOME}/soc-workflows "* ]]
  [[ "${output}" != *"${HOME}/portal/wt"* ]]
}

@test "gh-review refuses a PR whose repo is not cloned instead of using the cwd" {
  cd "${HOME}/portal/wt"

  run gh_review --detached --non-interactive --tier sonnet \
    "https://github.com/huntresslabs/sigma/pull/7"
  [ "${status}" -ne 0 ]
  [[ "${output}" == *"sigma"* ]]

  run refute_tmux_subcommand "display-popup"
  [ "${status}" -eq 0 ]
}

# The classifier reads a PR by reference through gh, so a bare number resolves
# against the caller's repository: portal#205, not soc-workflows#205. Same root
# cause as the worktree, one call frame over.
@test "gh-review classifies the PR the URL names, not the cwd repo's same number" {
  cd "${HOME}/portal/wt"

  run gh_review --detached --non-interactive \
    "https://github.com/huntresslabs/soc-workflows/pull/205"
  [ "${status}" -eq 0 ]

  run grep -c "title,body,files" "${GH_STUB_LOG}"
  [ "${output}" -ge 1 ]

  run grep "title,body,files" "${GH_STUB_LOG}"
  [[ "${output}" == *"soc-workflows/pull/205"* ]]
}

# A bare number carries no repository, so the caller's directory stays the
# answer and gh resolves the PR against it. This is the path every manual
# `gh-review 123` takes.
# The two halves of the read-only review session, and neither is safe alone:
# bypassPermissions with no CLAUDE_READONLY_REMOTE hands the model an unprompted
# push, and the env var without the bypass just reinstates the prompts.
@test "gh-review launches the review with permissions bypassed and remotes read-only" {
  cd "${HOME}/portal/wt"

  run gh_review --detached --non-interactive --tier sonnet 205
  [ "${status}" -eq 0 ]

  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"CLAUDE_READONLY_REMOTE=1 claude "* ]]
  [[ "${output}" == *"--permission-mode bypassPermissions"* ]]
}

@test "gh-review keeps using the working directory for a bare PR number" {
  cd "${HOME}/portal/wt"

  run gh_review --detached --non-interactive --tier sonnet 205
  [ "${status}" -eq 0 ]

  run popup_command
  [[ "${output}" == *"cd ${HOME}/portal/wt "* ]]
}
