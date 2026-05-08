#!/usr/bin/env bash
# PreToolUse hook: block "git add -A", "git add --all", and "git add ." —
# stage specific files by name to avoid sweeping in secrets, .env, or stray
# binaries. Bypass with the comment marker `# allow-git-add-all`.

set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -z "$cmd" ] && exit 0

if echo "$cmd" | grep -qF '# allow-git-add-all'; then
  exit 0
fi

if echo "$cmd" | grep -qE '(^|[[:space:];&|])git[[:space:]]+add[[:space:]]+(-A|--all|\.)([[:space:]]|$)'; then
  jq -n '{
    "decision": "block",
    "reason": "Stage specific files by name (git add path/to/file). -A, --all, and . can sweep in .env, secrets, or unintended files. Bypass with a `# allow-git-add-all` comment in the command."
  }'
fi
