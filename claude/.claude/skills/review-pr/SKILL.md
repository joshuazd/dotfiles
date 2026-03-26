---
description: Review a pull request — focuses on architecture, design, and pattern adherence
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git merge-base*), Bash(git rev-parse*)
---

You are already in a git worktree with this PR's branch checked out. You can read files directly to get additional context beyond the diff.

Review this pull request. Most code you review is Claude-generated — it tends to be correct but often introduces new patterns instead of following existing ones, over-engineers, or doesn't reuse existing utilities.

Your primary lens is **architecture & design**. Before reporting any finding, verify it against the actual codebase. Skip formatting, naming, and style preferences.

### Architecture & Design (primary focus)

For every changed file, read the surrounding code and related modules to answer:
- **Pattern adherence:** Does the code follow existing patterns in the codebase, or does it introduce new ones unnecessarily?
- **Reuse:** Are existing helpers, utilities, abstractions, and components reused? Or are wheels being reinvented? Point to the existing code that should have been used.
- **Abstraction level:** Is there over-engineering, premature abstraction, unnecessary helpers, or excessive config? Three similar lines > a premature abstraction.
- **Right layer/module:** Does the code land where it belongs architecturally? Is there tight coupling that shouldn't exist?
- **Maintenance cost:** Will this cause pain later? Would a simpler approach work?

### Blocking Issues (secondary)

Also flag anything that must be fixed before merge:
- Bugs, logic errors, data loss, race conditions
- Security vulnerabilities
- Significant performance problems
- Missing error handling for realistic failure cases

## What's Missing

Go beyond the diff. Read surrounding code, related files, and callers/consumers to identify things the PR *should* have done but didn't:
- Callers or consumers that need updating to match new behavior
- Related tests that should exist but don't (end-to-end, not just line coverage)
- Database migrations or schema changes the new code implies
- Permissions, authorization, or access control new features need
- Edge cases or code paths the changes don't handle

Only flag things that are genuinely missing and would cause problems. Don't flag nice-to-haves.

Format your output as:

## Summary
Brief explanation of *what* the PR does and *why* (2-3 sentences max). Derive this from the diff, title, and description.

## Architecture & Design
(one bullet per finding: `file:line` — what the problem is, and point to the existing pattern/utility that should have been used; or "(none)")

Categories to cover:
- Pattern violations (with pointer to existing pattern)
- Over-engineering / unnecessary abstractions
- Wrong layer / tight coupling
- Reinvented wheels (with pointer to existing utility)

## Blocking Issues
(one bullet per finding: `file:line` — what's wrong and why it matters; or "(none)")
Only bugs, security, data loss, race conditions, or significant performance problems.

## What's Missing
(one bullet per gap: what's missing, where it should be, and why it matters; or "(none)")

**Ready to merge:** Yes / No / With fixes

If there are no issues, skip the sections and just say so with the verdict.

**Conciseness:** Be extremely concise. No filler, no preamble, no summaries. Push back on silly ideas.

---

!`gh pr view $ARGUMENTS --json title,body -q '("## ") + .title + "\n\n" + .body'`

## Comments and Reviews

!`gh pr view $ARGUMENTS --json comments,reviews`

After loading the diff, fetch **unresolved** inline review comments using GraphQL (the REST API does not expose resolution status). Extract owner, repo, and PR number from the PR data above:
```
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          comments(first: 10) {
            nodes {
              body
              author { login }
              path
              line
              createdAt
            }
          }
        }
      }
    }
  }
}' -f owner="{owner}" -f repo="{repo}" -F pr={number}
```

Only consider threads where `isResolved: false` and `isOutdated: false`. Skip resolved and outdated conversations entirely.

### Greptile Comments

Some unresolved threads may be from Greptile (an automated reviewer). For each unresolved Greptile comment:
- Verify the claim against the actual code in the diff.
- If valid, include it in the appropriate section like any other finding.
- If invalid or incorrect, call it out explicitly (e.g. "`file:line` — Greptile flagged X but this is incorrect because Y").

Do not trust Greptile blindly — treat its comments as hints to investigate, not conclusions.

## Diff

!`gh pr diff $ARGUMENTS`
