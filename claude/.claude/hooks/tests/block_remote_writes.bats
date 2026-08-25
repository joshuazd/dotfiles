#!/usr/bin/env bats
#
# The hook is an allowlist guarding sessions that run with permissions
# bypassed, so both directions matter: a missed deny publishes something, and a
# spurious deny stalls the review.

setup() {
  HOOK="${BATS_TEST_DIRNAME}/../block-remote-writes.sh"
  export CLAUDE_READONLY_REMOTE=1
}

# Run the hook over a Bash command, as Claude would.
hook_bash() {
  jq -n --arg c "${1}" '{tool_name:"Bash",tool_input:{command:$c}}' | bash "${HOOK}"
}

hook_tool() {
  jq -n --arg t "${1}" '{tool_name:$t,tool_input:{}}' | bash "${HOOK}"
}

assert_denied() {
  [ -n "${output}" ]
  [ "$(printf '%s' "${output}" | jq -r '.hookSpecificOutput.permissionDecision')" = "deny" ]
}

assert_allowed() {
  if [ -n "${output}" ]; then
    printf 'expected no output, got status %s and:\n%s\n' "${status}" "${output}" >&2
    return 1
  fi
}

@test "an unarmed session is untouched" {
  unset CLAUDE_READONLY_REMOTE
  run hook_bash "git push origin HEAD"
  assert_allowed
}

@test "git push is denied, however it is spelled" {
  local cmd
  for cmd in "git push origin HEAD" \
             "git push --force-with-lease" \
             "git -C /tmp/wt push" \
             "echo hi && git push" \
             "echo \$(git push)" \
             "git remote set-url origin git@example.com:o/r"; do
    run hook_bash "${cmd}"
    assert_denied
  done
}

@test "read-only git is allowed" {
  local cmd
  for cmd in "git fetch origin" "git log --oneline -5" "git diff main...HEAD" \
             "git remote -v" "rg 'git push' lib/"; do
    run hook_bash "${cmd}"
    assert_allowed
  done
}

@test "gh writes are denied" {
  local cmd
  for cmd in "gh pr comment 123 --body hi" \
             "gh pr merge 123" \
             "gh pr ready 123" \
             "gh pr create --draft" \
             "gh issue create -t x"; do
    run hook_bash "${cmd}"
    assert_denied
  done
}

@test "gh reads are allowed" {
  local cmd
  for cmd in "gh pr view 123 --json title,body" "gh pr diff 123" \
             "gh run list" "gh repo view"; do
    run hook_bash "${cmd}"
    assert_allowed
  done
}

@test "gh api passes only when it cannot write" {
  run hook_bash "gh api repos/o/r/pulls/1/comments"
  assert_allowed
  run hook_bash "gh api graphql -f query='query { repository { x } }'"
  assert_allowed
  run hook_bash "gh api -X DELETE /repos/o/r/issues/comments/1"
  assert_denied
  run hook_bash "gh api graphql -f query='mutation { addComment }'"
  assert_denied
  run hook_bash "gh api repos/o/r/issues/1/comments -f body=hi"
  assert_denied
}

@test "an unrecognised gh subcommand is denied, not allowed" {
  run hook_bash "gh alias set x y"
  assert_denied
}

@test "short only reads" {
  run hook_bash "short story 12345"
  assert_allowed
  run hook_bash "short search 'owner:me'"
  assert_allowed
  run hook_bash "short story 12345 --comment 'hi'"
  assert_denied
  run hook_bash "short story 12345 -s 'In Review'"
  assert_denied
  run hook_bash "short create --title x"
  assert_denied
}

@test "curl bodies are denied" {
  run hook_bash "curl -s https://example.com"
  assert_allowed
  run hook_bash "curl -X POST https://hooks.slack.com/x"
  assert_denied
}

@test "MCP tools are allowed only when read-shaped" {
  run hook_tool "mcp__plugin_slack_slack__slack_read_thread"
  assert_allowed
  run hook_tool "mcp__datadog-mcp__search_datadog_logs"
  assert_allowed
  run hook_tool "mcp__plugin_slack_slack__slack_send_message"
  assert_denied
  run hook_tool "mcp__plugin_slack_slack__slack_update_canvas"
  assert_denied
}
