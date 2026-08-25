---
name: self-review-pr
description: Use when reviewing your own pull request or your own in-progress branch — the work is yours, the PR is typically a draft, and small problems should be fixed rather than reported. Also invoked by watch-pull-request as its self-review gate. For reviewing someone else's PR, use review-pr instead.
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git diff:*), Bash(short story:*), Bash(rg:*), Bash(grep:*), Read, Edit, Write, Glob, Grep
---

# Self-Review PR

Reviewing your own work-in-progress PR. Same analysis as `review-pr`, different disposition: **you have write access and you are the author, so anything small enough to fix, you fix.** Only findings that need a human decision get reported.

You are usually dispatched as a subagent. The main agent owns commits, pushes, and the big changes. You own the working tree edits for small stuff and the report.

## Preconditions

Same as `review-pr`. Confirm HEAD matches the PR head SHA, load PR context, load unresolved inline threads, load the linked story:

```
gh pr view <pr> --json title,body,headRefOid,url,isDraft
git rev-parse HEAD
gh pr diff <pr>
short story --from-git -q
```

If HEAD differs from the PR head SHA, stop — do not edit a working tree that isn't the PR's state.

## Analysis Lenses

Read `~/.claude/skills/review-pr/SKILL.md` and apply its **Architecture & Design**, **State Machine Changes**, **Blocking Issues** (including Functional Completeness), and **What's Missing** sections. Ignore its Output Format and its "report, don't touch" framing — this skill's Fix Policy and Output Format below replace them.

Plus one lens `review-pr` doesn't have: the **Comment Audit** below.

**You are not CI.** Don't run linters, builds, or the test suite. Read-only `rg`/`grep`/file reads to verify a specific finding are fine and expected.

## Comment Audit

**Almost every comment in a diff is unnecessary. The default disposition is delete.**

Audit every comment on a line the PR added or modified. Pre-existing comments on untouched lines are out of scope.

**Delete:**
- Restates what the code says (`# increment the counter`, `# fetch the user`)
- Narrates the diff or the implementation order (`# Now we check X`, `# Step 2:`)
- Section headers inside a method (`# Setup`, `# Validation`)
- Explains something a better name would explain — **rename instead of commenting**
- Commented-out code
- Changelog/provenance chatter (`# Added for sc-12345`, `# Per review feedback`)
- `TODO` with no ticket reference
- Docstring-style comments restating the method signature and its params

**Keep (rare):**
- A *why* that cannot be inferred from the code: a non-obvious constraint, an ordering requirement, a deliberate deviation
- A workaround anchored to an external bug/ticket/upstream issue
- Required annotations: `rubocop:disable`, magic comments, i18n/schema pragmas
- Genuinely opaque logic (a regex, a bit-twiddle, a formula) where the comment states intent

**Test:** cover the comment and read the code. If you still understand it, delete the comment. If you don't, first try renaming a variable or method so you do — only if that fails does the comment earn its place.

Deleting comments and renaming to replace them is a **fix**, not a finding. Do it. Don't list every deleted comment individually in the report — give a count and mention only the ones you kept and why.

## Fix Policy

**Fix directly** — mechanical, behavior-preserving, confined to files the PR already touches:
- Comment removals and the renames that replace them
- Naming (variables, methods, specs) that reads poorly
- Dead code, unused variables/params/requires, leftover debug output
- Swapping a hand-rolled snippet for an existing helper that is a drop-in replacement
- Duplication that collapses without inventing an abstraction
- Typos, wrong i18n keys, copy-paste artifacts

**Surface, don't fix** — anything needing a judgment call the author should own:
- Anything that changes behavior, including bug fixes
- Architectural moves: new abstractions, relocating code across layers, changing an interface
- Missing tests, missing migrations, missing authorization
- Half-wired state machines and incomplete features
- Edits to files outside the PR's diff
- Anything you're not confident about

**When in doubt, surface it.** A wrong silent edit costs more than a line in the report.

### Constraints

- **Do not commit. Do not push. Do not amend.** Leave edits in the working tree; the main agent commits them.
- **Do not `git checkout`, `git stash`, or revert anything.** The user's uncommitted work may be in the tree.
- **Do not reply to comments on GitHub.** Not to humans, not at all from this skill.
- Every fix must be visible in the report. Nothing silent.
- If a fix touches non-comment code, name the spec files that cover it so the main agent can run them.

## Greptile and Human Comments

Unresolved inline threads (see `review-pr`'s Comments and Reviews section for the GraphQL query) are input, not gospel. For each: verify the claim against the code. If valid and small, fix it and list it under Fixed. If valid and large, surface it. If wrong, list it under Rejected with the one-line reason.

## Output Format

Findings you fixed go first — they're already true. Findings needing a decision go second. Prose last and tiny.

```
**Merge:** Yes / No / With fixes
```

Then, omitting any section that's empty:

```
## Fixed (in working tree, uncommitted)
- `file:line` — what changed, ≤12 words.

## Needs your call
- `file:line` **[TAG]** Headline — ≤15 words.
  ↳ optional: ONE short clause. Skip unless the headline can't stand alone.

## Rejected
- `file:line` — Greptile flagged X; wrong because Y.

## Specs to run
`spec/path/a_spec.rb spec/path/b_spec.rb`

## Summary
1-2 sentences: what the PR does and why.
```

Tags for **Needs your call**: `[BLOCK]` bug/security/data loss/race/perf/half-wired, `[DESIGN]` pattern violation/over-engineering/wrong layer/reinvented wheel (always point at the existing thing), `[MISSING]` caller/test/migration/permission/edge case.

Comment audit result is one line at the top of **Fixed**: `Comments: N removed, M kept.` List a kept comment only if the reason isn't obvious.

Rules:
- Headlines are the comment you'd type, not a description of it. ≤15 words.
- At most ONE `↳` sub-line per finding. Most have zero.
- If a finding needs a paragraph, you're writing prose — cut it. The user will ask.
- Verdict "Yes" with nothing fixed and nothing to decide → output the verdict line and Summary only.

## Note on non-draft PRs

This skill assumes your own in-progress work. If `isDraft` is false and humans have already reviewed, still fix the small things — but say so plainly at the top of the report so the user knows reviewers are looking at a moved target.

## Red Flags

| Thought | Reality |
|---------|---------|
| "This comment explains the intent" | Cover it and read the code. If you still get it, delete it. |
| "I'll add a comment explaining the fix" | You just created the thing you're auditing for. |
| "It's a small behavior change, I'll just do it" | Behavior changes are never small enough. Surface it. |
| "I'll commit so it's not lost" | The main agent commits. Working tree only. |
| "I'll list this as a finding, it's faster" | If it's mechanical and in-diff, fix it. That's the whole point of this skill. |
| "Let me run the test suite to be sure" | CI does that. Name the specs and move on. |
