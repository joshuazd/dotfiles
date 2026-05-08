#!/usr/bin/env bash
# PreToolUse hook: block `gh pr ready` (marking a draft PR as ready for
# review). Override by setting CLAUDE_ALLOW_PR_READY=1 in the environment
# before invoking the command.

set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -z "$cmd" ] && exit 0

if [ "${CLAUDE_ALLOW_PR_READY:-}" = "1" ]; then
  exit 0
fi

if echo "$cmd" | grep -qE '(^|[[:space:];&|])gh[[:space:]]+pr[[:space:]]+ready([[:space:]]|$)'; then
  jq -n '{
    "decision": "block",
    "reason": "Do not mark a draft PR as ready for review. To override, prefix the command with CLAUDE_ALLOW_PR_READY=1 (e.g., CLAUDE_ALLOW_PR_READY=1 gh pr ready 1234)."
  }'
fi
