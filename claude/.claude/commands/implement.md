---
description: Implement a Shortcut story — follows project conventions and writes tests
argument-hint: <story-id>
allowed-tools: Bash(short story:*), Bash(gh pr view*)
---

Please implement the following Shortcut story.

Instructions: Before writing any implementation code, invoke the `superpowers:test-driven-development`
skill. Then implement the story as described. Create a working implementation,
write tests where appropriate, and follow the existing code patterns and conventions
in the project. Ask me if anything in the requirements is unclear before proceeding.

---

!`short story "$ARGUMENTS" --format "%j" | jq -r '"## " + .name + "\n\n" + (.description // "")'`
