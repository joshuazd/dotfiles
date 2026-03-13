---
description: Review a pull request — flags bugs, security issues, and significant problems
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git merge-base*), Bash(git rev-parse*)
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

Also note architectural concerns separately — poor design decisions worth flagging for awareness (e.g. inappropriate abstraction, tight coupling, violation of established patterns, decisions that will cause pain later). These are not blockers.

Format your output as:

## Issues

### Critical
(one bullet per finding: `file:line` — what's wrong and why it matters)

### Important
(same format, or "(none)")

### Minor
(same format, or "(none)")

## Architectural Concerns
(one bullet per concern: `file:line` — what the decision is and why it's worth reconsidering; or "(none)")

**Ready to merge:** Yes / No / With fixes

If there are no issues, skip the sections and just say so with the verdict.

**Conciseness:** Be extremely concise. No filler, no preamble, no summaries. Push back on silly ideas.

---

!`gh pr view $ARGUMENTS --json title,body -q '("## ") + .title + "\n\n" + .body'`

## Comments and Reviews

!`gh pr view $ARGUMENTS --json comments,reviews`

After loading the diff, fetch inline review comments using the PR number (extract from the PR data above):
```
gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {user: .user.login, path, line, original_line, body}'
```

## Diff

!`gh pr diff $ARGUMENTS`
