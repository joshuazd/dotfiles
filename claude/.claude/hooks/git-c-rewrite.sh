#!/usr/bin/env bash
# PreToolUse hook: rewrite "git -C <path> ..." to "git ..." when <path> resolves
# to the current working directory. Removes redundant -C and lets the rewritten
# command match existing allowlist entries.

set -euo pipefail

input="$(cat)"
cmd="$(echo "$input" | jq -r '.tool_input.command // ""')"
cwd="$(echo "$input" | jq -r '.cwd // ""')"

[ -z "$cmd" ] && exit 0
[ -z "$cwd" ] && exit 0

# Match: leading "git -C <path> <rest>"; <path> may be quoted.
if [[ "$cmd" =~ ^([[:space:]]*git[[:space:]]+-C[[:space:]]+)(\"[^\"]+\"|\'[^\']+\'|[^[:space:]]+)([[:space:]]+.*)$ ]]; then
  path_arg="${BASH_REMATCH[2]}"
  rest="${BASH_REMATCH[3]}"

  # Strip surrounding quotes
  unquoted="${path_arg%\"}"; unquoted="${unquoted#\"}"
  unquoted="${unquoted%\'}"; unquoted="${unquoted#\'}"

  # Expand leading tilde (quote ~ to prevent bash tilde-expansion in the pattern)
  case "$unquoted" in
    "~"|"~/"*) expanded="${HOME}${unquoted#"~"}" ;;
    *) expanded="$unquoted" ;;
  esac

  # Canonicalize both paths; bail silently if either can't be resolved.
  resolved_path="$(cd "$expanded" 2>/dev/null && pwd -P)" || exit 0
  resolved_cwd="$(cd "$cwd" 2>/dev/null && pwd -P)" || exit 0

  if [ "$resolved_path" = "$resolved_cwd" ]; then
    new_cmd="git${rest}"
    jq -n --arg cmd "$new_cmd" \
      '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":$cmd}}}'
  fi
fi
