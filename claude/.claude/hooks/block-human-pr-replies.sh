#!/usr/bin/env bash
# Block replies to human reviewers on PR threads.
# Only Greptile bot (login starts with "greptile") may receive replies.
# Claude must NEVER reply to human reviewers — the user posts, not Claude.

command=$(jq -r '.tool_input.command // ""')

# Only intercept pull request comment reply calls
if ! echo "$command" | grep -qE 'pulls/[0-9]+/comments/[0-9]+/replies'; then
  exit 0
fi

# Extract comment ID (the one before /replies)
comment_id=$(echo "$command" | grep -oE 'comments/[0-9]+/replies' | grep -oE '[0-9]+')
# Extract owner/repo path
nwo=$(echo "$command" | grep -oE 'repos/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | head -1)

# gh's {owner}/{repo} placeholder form won't match the regex above; resolve from
# the current repo context instead.
if [ -z "$nwo" ]; then
  repo=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
  [ -n "$repo" ] && nwo="repos/$repo"
fi

# We're already past the /replies gate, so this IS a reply attempt. Missing data
# means we can't verify the recipient - fail safe by blocking, never allowing.
if [ -z "$comment_id" ] || [ -z "$nwo" ]; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: could not resolve PR/comment to verify recipient. Refusing to reply - check manually."}}'
  exit 0
fi

author=$(gh api "$nwo/pulls/comments/$comment_id" --jq '.user.login' 2>/dev/null)

# If we can't determine the author, fail safe by blocking
if [ -z "$author" ]; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOCKED: could not verify PR comment author. Refusing to reply — check manually."}}'
  exit 0
fi

# Allow Greptile bot replies
if echo "$author" | grep -qi '^greptile'; then
  exit 0
fi

# Block: human reviewer
jq -n --arg a "$author" '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":("BLOCKED: you are replying to human reviewer \"" + $a + "\". You did this before and were called out for it. The user posts, not you. Report the feedback in conversation instead.")}}'
exit 0
