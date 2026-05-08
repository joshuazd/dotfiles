#!/usr/bin/env bash
# PreToolUse hook: block `git push --force` and `git push -f`; require the
# safer `--force-with-lease`. Bypass with the comment marker
# `# allow-force-push`.

set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -z "$cmd" ] && exit 0

if echo "$cmd" | grep -qF '# allow-force-push'; then
  exit 0
fi

# Only inspect the args that follow `git push`. Stop at the first command
# separator so flags belonging to a chained command don't trigger us.
if ! echo "$cmd" | grep -qE '(^|[[:space:];&|])git[[:space:]]+push\b'; then
  exit 0
fi

post_push="${cmd#*git push}"
post_push="${post_push%%|*}"
post_push="${post_push%%;*}"
post_push="${post_push%%&&*}"

# Block --force (but allow --force-with-lease).
if echo "$post_push" | grep -qE '\-\-force([[:space:]]|$)'; then
  jq -n '{
    "decision": "block",
    "reason": "Do not git push --force. Use --force-with-lease so you do not silently overwrite upstream commits you have not seen. Bypass with `# allow-force-push`."
  }'
  exit 0
fi

# Block standalone -f as an arg to git push.
if echo "$post_push" | grep -qE '(^|[[:space:]])-f([[:space:]]|$)'; then
  jq -n '{
    "decision": "block",
    "reason": "Do not git push -f. Use --force-with-lease. Bypass with `# allow-force-push`."
  }'
  exit 0
fi
