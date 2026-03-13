---
name: ruby-rubocop
description: Use when running Rubocop or fixing Rubocop offenses in Ruby/Rails projects. Provides known offense patterns and fixes.
version: 1.0.0
---

# Ruby Rubocop

## Automatic Linting

Rubocop runs automatically via a PostToolUse hook on every Edit/Write to a Ruby file. No need to run it manually.

## Known offense patterns

### Style/YAMLFileRead
Use `YAML.safe_load_file(path, aliases: true)` — not `YAML.safe_load(File.read(path), ...)`.

### RSpec/RepeatedSubjectCall
Two `expect { subject }` calls in the same example are an offense because `subject` is memoized on first call. Split into separate `it` blocks instead.

### Layout/EmptyLinesAroundBlockBody
After deleting lines inside a block, check for stray blank lines at the start or end of the block body.
