---
description: Review a pull request — focuses on architecture, design, and pattern adherence
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(short story:*), Bash(rg:*), Bash(grep:*)
---

You are reviewing a pull request. The expectation is that you are already in a git worktree with this PR's branch checked out. You can read files directly to get additional context beyond the diff.

## Preconditions

1. **Verify checkout** — confirm HEAD matches the PR head SHA before proceeding:
   ```
   gh pr view <pr> --json headRefOid -q .headRefOid
   git rev-parse HEAD
   ```
   If they differ, stop and tell the user the worktree is on the wrong commit.

2. **Load PR context** — run these to load the title/body, top-level comments, reviews, and diff:
   ```
   gh pr view <pr> --json title,body,headRefOid,url
   gh pr view <pr> --json comments,reviews
   gh pr diff <pr>
   ```

3. **Load unresolved inline review threads** — see [Comments and Reviews](#comments-and-reviews) below. The `gh` skill covers the three-API problem; consult it if anything is unclear.

4. **Load the linked story** — see [Linked Story](#linked-story) below.

Review this pull request. Most code you review is Claude-generated — it tends to be correct but often introduces new patterns instead of following existing ones, over-engineers, or doesn't reuse existing utilities.

Your primary lens is **architecture & design**. Before reporting any finding, verify it against the actual codebase (use `rg` to confirm patterns exist where you claim). Skip formatting, naming, and style preferences. Invoke `superpowers:verification-before-completion` before posting findings.

## Architecture & Design (primary focus)

For every changed file, read the surrounding code and related modules to answer:
- **Pattern adherence:** Does the code follow existing patterns in the codebase, or does it introduce new ones unnecessarily?
- **Reuse:** Are existing helpers, utilities, abstractions, and components reused? Or are wheels being reinvented? Point to the existing code that should have been used.
- **Abstraction level:** Is there over-engineering, premature abstraction, unnecessary helpers, or excessive config? Three similar lines > a premature abstraction.
- **Right layer/module:** Does the code land where it belongs architecturally? Is there tight coupling that shouldn't exist?
- **Maintenance cost:** Will this cause pain later? Would a simpler approach work?

## State Machine Changes

When a PR adds, removes, or modifies a status/state/enum value:
1. **List all states** the model can be in (read the model, not just the diff)
2. **Draw the transition map** — for the new/changed state, explicitly list: what states lead INTO it, and what states it transitions OUT to
3. **Verify each transition has a trigger** — not just decision logic, but the code that *invokes* that logic. A correct if/else branch is useless if nothing calls it. Trace from the trigger (job, callback, controller action, event handler) through to the state change.
4. **Check both directions** — if the PR adds entry into a state, verify there's a way out. If it adds an exit, verify something can enter.
5. Common miss: adding an intermediate state with correct entry but no exit trigger. The state becomes a dead end because nothing re-evaluates the model after entry conditions are met.

Half-wired state transitions are blocking issues, not nits.

## Blocking Issues

Also flag anything that must be fixed before merge:
- Bugs, logic errors, data loss, race conditions
- Security vulnerabilities
- Significant performance problems
- Missing error handling for realistic failure cases

### Functional Completeness

Read the PR description and any linked story/ticket. For each stated requirement or acceptance criterion:
- **Verify the diff delivers it.** Not "the code is structured to support it" — does the actual behavior exist end-to-end?
- **Trace the happy path** from trigger to outcome. If the story says "X should happen when Y," find the code for Y triggering and X resulting.
- **Watch for half-wired features:** new states with no exit, new columns with no writer, new permissions with no enforcement, new events with no subscriber. The code that's there is correct — but is the circuit complete?

If the PR description is vague, infer requirements from the code's intent and flag anything that looks incomplete.

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

## Comments and Reviews

PR comments live in **three** separate APIs — fetch all three or you'll miss context. The `gh` skill covers this in detail; the relevant queries:

1. **Top-level comments + reviews** (verdicts):
   ```
   gh pr view <pr> --json comments,reviews
   ```
   `reviews[].state` gives APPROVED / CHANGES_REQUESTED / COMMENTED.

2. **Unresolved inline review threads** (REST does not expose resolution status — must use GraphQL). Extract `owner`, `repo`, `number` from the `url` field of `gh pr view --json url` output:
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
               nodes { body author { login } path line createdAt }
             }
           }
         }
       }
     }
   }' -f owner=OWNER -f repo=REPO -F pr=NUMBER
   ```
   Only consider threads where `isResolved: false` AND `isOutdated: false`.

### Greptile Comments

Some unresolved threads may be from Greptile (an automated reviewer). For each unresolved Greptile comment:
- Verify the claim against the actual code in the diff.
- If valid, include it in the appropriate section like any other finding.
- If invalid or incorrect, call it out explicitly (e.g. "`file:line` — Greptile flagged X but this is incorrect because Y").

Do not trust Greptile blindly — treat its comments as hints to investigate, not conclusions.

## Linked Story

Fetch the Shortcut story for requirements context. The branch name typically contains the story ID (e.g., `jz/sc-12345/feature-name`):

```
short story --from-git -q
```

If `--from-git` fails (no story ID in branch name), check the PR description for a Shortcut URL or story ID and use `short story <ID> -q` instead.

Use the story's title, description, and acceptance criteria as the source of truth for the Functional Completeness check. If no story is linked, rely on the PR description and note that no story was found.
