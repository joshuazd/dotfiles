---
description: Review a pull request — flags bugs, security issues, and significant problems
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(git merge-base*), Bash(git rev-parse*)
---

You are already in a git worktree with this PR's branch checked out. You can read files directly to get additional context beyond the diff.

Review this pull request. Only flag things worth blocking or discussing.

Before reporting any finding, verify it is actually a problem in the diff. Skip formatting, naming, style preferences, and anything that does not affect correctness, security, or meaningful maintainability.

Report only:
- Bugs or logic errors
- Security vulnerabilities
- Data loss or race conditions
- Significant performance problems (not micro-optimizations)
- Missing error handling for realistic failure cases
- Significant missing tests for critical functionality

Format your output as:

## Issues

### Critical
(one bullet per finding: `file:line` — what's wrong and why it matters)

### Important
(same format, or "(none)")

### Minor
(same format, or "(none)")

**Ready to merge:** Yes / No / With fixes

If there are no issues, skip the sections and just say so with the verdict.

---

!`gh pr view $ARGUMENTS --json title,body -q '"## " + .title + "\n\n" + .body'`

## Comments and Reviews

!`gh pr view $ARGUMENTS --json comments,reviews -q '"## Comments\n\n" + (if (.comments | length) == 0 then "_(none)_" else [.comments[] | "**" + .author.login + ":** " + .body] | join("\n\n") end) + "\n\n## Reviews\n\n" + (if ([.reviews[] | select(.body | length > 0)] | length) == 0 then "_(none)_" else [.reviews[] | select(.body | length > 0) | "**" + .author.login + "** (" + .state + "): " + .body] | join("\n\n") end)'`

## Diff

!`gh pr diff $ARGUMENTS`
