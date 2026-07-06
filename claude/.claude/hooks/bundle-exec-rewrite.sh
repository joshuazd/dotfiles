#!/bin/bash
# Rewrite bin/<cmd> to bundle exec <cmd> for common Ruby tools
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
# Rewrite only when bin/<tool> sits at a command position (start, or after a
# shell separator), with a word boundary after the tool name - so `cat app/bin/rails`
# and `bin/rakefile` are left untouched.
REWRITTEN=$(printf '%s' "$COMMAND" | perl -pe 's{(^|[\s;&|(])(?:\./)?bin/(rails|rspec|rubocop|rake)\b}{$1bundle exec $2}g')
if [ "$COMMAND" != "$REWRITTEN" ]; then
  jq -n --arg cmd "$REWRITTEN" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":$cmd}}}'
fi
