---
description: Review a pull request — flags only bugs, security issues, and significant problems
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*)
---

You are already in a git worktree with this PR's branch checked out. You can read files directly to get additional context beyond the diff.

!`PR_HEAD=$(gh pr view "$ARGUMENTS" --json headRefOid -q '.headRefOid' 2>/dev/null); LOCAL_HEAD=$(git rev-parse HEAD 2>/dev/null); if [ -n "$PR_HEAD" ] && [ "$PR_HEAD" != "$LOCAL_HEAD" ]; then BRANCH=$(gh pr view "$ARGUMENTS" --json headRefName -q '.headRefName' 2>/dev/null); if git fetch origin "$BRANCH" --quiet 2>/dev/null && git reset --hard "origin/$BRANCH" 2>/dev/null; then echo "Worktree synced to PR HEAD ($PR_HEAD)"; else echo "Warning: worktree at $LOCAL_HEAD differs from PR HEAD ($PR_HEAD) — sync failed"; fi; fi`

Review this pull request. Be concise — only flag issues worth blocking or discussing.

Before reporting any finding, verify it is actually a problem in the diff. Do not
flag things that are handled correctly, already accounted for, or are style
preferences. Skip formatting, naming, minor refactoring suggestions, and anything
that does not affect correctness, security, or meaningful maintainability.

Report only:
- Bugs or logic errors
- Security vulnerabilities
- Data loss or race conditions
- Significant performance problems (not micro-optimizations)
- Missing error handling for realistic failure cases
- Significant missing tests for critical functionality

Format: one finding per bullet. Always include the file name and line number.
If you find nothing worth flagging, say so briefly.

---

!`gh pr view "$ARGUMENTS" --json title,body -q '"## " + .title + "\n\n" + .body'`

## Comments and Reviews

!`gh pr view "$ARGUMENTS" --json comments,reviews -q '"## Comments\n\n" + (if (.comments | length) == 0 then "_(none)_" else [.comments[] | "**" + .author.login + ":** " + .body] | join("\n\n") end) + "\n\n## Reviews\n\n" + (if ([.reviews[] | select(.body | length > 0)] | length) == 0 then "_(none)_" else [.reviews[] | select(.body | length > 0) | "**" + .author.login + "** (" + .state + "): " + .body] | join("\n\n") end)'`

## Diff

!`gh pr diff "$ARGUMENTS"`
