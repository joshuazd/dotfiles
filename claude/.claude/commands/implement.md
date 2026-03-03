---
description: Implement a Shortcut story — follows project conventions and writes tests
argument-hint: <story-id>
allowed-tools: Bash(short story:*), Bash(gh pr view*)
---

Please implement the following Shortcut story.

Instructions:
1. Invoke `superpowers:writing-plans` to create a structured implementation plan with TDD steps for each task. Save to `docs/plans/YYYY-MM-DD-<story-name>.md`.
2. After the plan is ready, invoke `superpowers:subagent-driven-development` to execute it with fresh subagents per task. If tasks are tightly coupled, use `superpowers:executing-plans` instead.

Ask me if anything in the requirements is unclear before proceeding.

---

!`short story "$ARGUMENTS" --format "%j" | jq -r '"## " + .name + "\n\n" + (.description // "")'`
