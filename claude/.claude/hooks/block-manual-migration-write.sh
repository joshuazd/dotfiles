#!/usr/bin/env bash
# PreToolUse hook on Write: block manual creation of Rails migration files
# (db/migrate/*.rb) and ephemeral seed files (db/seeds*.rb). Edits to existing
# files are allowed — only new-file creation is blocked.

set -euo pipefail

file_path="$(jq -r '.tool_input.file_path // ""')"
[ -z "$file_path" ] && exit 0

# Only block creation; allow edits to existing files.
[ -e "$file_path" ] && exit 0

case "$file_path" in
  */db/migrate/*.rb)
    jq -n '{
      "decision": "block",
      "reason": "Do not create migration files manually. Use: bin/rails generate migration <Name> <args>. The generator gives you a correct timestamp, schema_migrations entry, and project conventions."
    }'
    exit 0
    ;;
esac

# Match db/seeds.rb, db/seeds/*.rb, db/seeds_*.rb
if echo "$file_path" | grep -qE '/db/seeds(/[^/]+|_[^/]*)?\.rb$'; then
  jq -n '{
    "decision": "block",
    "reason": "Do not create seed files for ephemeral data. Use bin/rails runner or the Rails console for one-off setup. Seed files are reserved for persistent, idempotent data."
  }'
  exit 0
fi
