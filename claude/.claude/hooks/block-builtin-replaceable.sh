#!/usr/bin/env bash
# PreToolUse hook: block Bash commands that should use built-in tools instead.
# Reads JSON from stdin, extracts .tool_input.command, checks against patterns.

set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -z "$cmd" ] && exit 0

# Escape hatch: a "# allow-bash" comment in the command bypasses all checks.
if echo "$cmd" | grep -qF '# allow-bash'; then
  exit 0
fi

# Pipelines, process substitution, and command substitution are handled by the
# LLM-review hook downstream. Don't second-guess them here.
if echo "$cmd" | grep -qE '\||<\(|>\(|\$\(|`'; then
  exit 0
fi

# Strip leading whitespace and ALL leading variable assignments
# (handles FOO=1 BAR=2 cmd, FOO="a b" cmd, FOO='a b' cmd).
stripped="$(echo "$cmd" | sed 's/^[[:space:]]*//')"
while echo "$stripped" | grep -qE '^[A-Za-z_][A-Za-z_0-9]*='; do
  stripped="$(echo "$stripped" | sed -E 's/^[A-Za-z_][A-Za-z_0-9]*=("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]*)[[:space:]]*//')"
done

first="$(echo "$stripped" | awk '{print $1}' | sed 's|.*/||')"

reason=""
case "$first" in
  cat)
    # Block only bare "cat <file>" reading a single file to stdout.
    if echo "$stripped" | grep -qE '^cat[[:space:]]+[^[:space:]<>]+[[:space:]]*$'; then
      reason="Use the Read tool instead of cat"
    fi
    ;;
  sed)
    # Block in-place editing (-i, -i.bak) or redirected output to a file.
    if echo "$stripped" | grep -qE '[[:space:]]-i([[:space:]]|\.|$)|>[[:space:]]*[^[:space:]]+'; then
      reason="Use the Edit tool instead of sed for file editing"
    fi
    ;;
  awk)
    if echo "$stripped" | grep -qE '[[:space:]]-i[[:space:]]+inplace|>[[:space:]]*[^[:space:]]+'; then
      reason="Use the Edit tool instead of awk for file editing"
    fi
    ;;
  echo|printf)
    if echo "$stripped" | grep -qE '>[[:space:]]*[^[:space:]]+'; then
      reason="Use the Write tool instead of $first with redirection"
    fi
    ;;
esac

if [ -n "$reason" ]; then
  jq -n --arg reason "$reason" '{
    "decision": "block",
    "reason": $reason
  }'
fi
