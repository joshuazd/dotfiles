#!/usr/bin/env bash
# PreToolUse hook: rewrite "gh pr create ..." invocations to enforce the
# standard PR creation policy:
#   - always --draft (unless already present)
#   - always --label ai-assisted (unless already present)
#   - always --label "TEAM: SOC" when the working directory belongs to
#     huntresslabs/portal (unless already present)

set -euo pipefail

input="$(cat)"
cmd="$(echo "$input" | jq -r '.tool_input.command // ""')"
cwd="$(echo "$input" | jq -r '.cwd // ""')"

[ -z "$cmd" ] && exit 0

# Only operate on actual `gh pr create` invocations.
if ! echo "$cmd" | grep -qE '(^|[[:space:];&|])gh[[:space:]]+pr[[:space:]]+create([[:space:]]|$)'; then
  exit 0
fi

new_cmd="$cmd"

# 1) Add --draft if not already specified.
if ! echo "$new_cmd" | grep -qE '\-\-draft([[:space:]]|$)'; then
  new_cmd="$(echo "$new_cmd" | sed -E 's/(gh[[:space:]]+pr[[:space:]]+create)/\1 --draft/')"
fi

# 2) Add --label ai-assisted if not already specified.
if ! echo "$new_cmd" | grep -qE '\-\-label[[:space:]]+("?ai-assisted"?)([[:space:]]|$)'; then
  new_cmd="$(echo "$new_cmd" | sed -E 's/(gh[[:space:]]+pr[[:space:]]+create)/\1 --label ai-assisted/')"
fi

# 3) When in huntresslabs/portal, also add --label "TEAM: SOC".
remote_url=""
if [ -n "$cwd" ]; then
  remote_url="$(cd "$cwd" 2>/dev/null && git config --get remote.origin.url 2>/dev/null || true)"
fi

if echo "$remote_url" | grep -qE '[:/]huntresslabs/portal(\.git)?$'; then
  if ! echo "$new_cmd" | grep -qE '\-\-label[[:space:]]+"TEAM:[[:space:]]*SOC"'; then
    new_cmd="$(echo "$new_cmd" | sed -E 's/(gh[[:space:]]+pr[[:space:]]+create)/\1 --label "TEAM: SOC"/')"
  fi
fi

if [ "$cmd" != "$new_cmd" ]; then
  jq -n --arg cmd "$new_cmd" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":$cmd}}}'
fi
