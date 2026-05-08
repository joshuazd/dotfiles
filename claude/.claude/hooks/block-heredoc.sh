#!/usr/bin/env bash
# PreToolUse hook: block heredoc syntax (<<EOF, <<'EOF', <<-EOF) in Bash.
# Use the Write tool for creating files, or `printf | cmd` / `cmd <<< "..."`
# to feed stdin. Bypass with the comment marker `# allow-heredoc`.

set -euo pipefail

cmd="$(jq -r '.tool_input.command // ""')"
[ -z "$cmd" ] && exit 0

if echo "$cmd" | grep -qF '# allow-heredoc'; then
  exit 0
fi

# Match `<<` (optionally `<<-`) followed by optional whitespace, optional
# quote, then a word character. This excludes `<<<` (here string) because
# the next char after `<<` would be `<`, not a word char.
if echo "$cmd" | grep -qE '<<-?[[:space:]]*['\''"]?[A-Za-z_]'; then
  jq -n '{
    "decision": "block",
    "reason": "Heredoc syntax (<<EOF) is forbidden. Use the Write tool to create files. To pipe text to a CLI use printf %s ... | cmd or cmd <<< \"text\". For multi-line content, write a file and pass it (e.g., git commit -F path). Bypass with a `# allow-heredoc` comment in the command."
  }'
fi
