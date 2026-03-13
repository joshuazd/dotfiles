---
name: gh
description: Use when performing any GitHub operations — viewing PRs, reading comments (especially inline review comments), checking CI status, or interacting with issues. Covers the common pitfalls with `gh` that lead to missing data.
---

# GitHub CLI (`gh`) Reference

## PR Comments — The Three Separate APIs

GitHub stores PR comments in three separate collections. This is the #1 source of missed context — `gh pr view --json comments` only returns top-level conversation comments (#1 below), **not** inline review comments.

### 1. Top-level conversation comments

General discussion and bot messages in the main thread.

```sh
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --jq '.[] | {user: .user.login, body: .body}'
```

These are also available via `gh pr view {number} --json comments`, but that's all you get from that JSON field.

### 2. Inline review comments (most important for code feedback)

Comments left on specific lines of code in the diff. **This is the one that gets missed.**

```sh
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {user: .user.login, path, line, original_line, body: .body, in_reply_to_id}'
```

Key fields:
- `path` — file the comment is on
- `line` — current diff line (null if the code has changed since the comment)
- `original_line` — line at time of review (always populated)
- `diff_hunk` — surrounding diff context
- `in_reply_to_id` — links threaded replies to their parent comment
- `subject_type` — "line" or "file"

### 3. Review verdicts

The top-level body of a review submission (APPROVED, CHANGES_REQUESTED, COMMENTED).

```sh
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --jq '.[] | {id, user: .user.login, state, body: .body}'
```

Get inline comments belonging to a specific review:
```sh
gh api repos/{owner}/{repo}/pulls/{number}/reviews/{review_id}/comments \
  --jq '.[] | {path, line, body: .body}'
```

### Reading all reviewer feedback

To get the full picture, always fetch both inline comments (#2) and reviews (#3):

```sh
# Inline review comments
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {user: .user.login, path, line, body: .body}'

# Review verdicts (filter to actionable ones)
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --jq '.[] | select(.state == "CHANGES_REQUESTED" or .state == "APPROVED") | {user: .user.login, state, body: .body}'
```

## Common PR Operations

```sh
# Structured PR data
gh pr view {number} --json title,state,body,author,baseRefName,headRefName,files,commits

# Diff
gh pr diff {number}              # full diff
gh pr diff {number} --name-only  # just changed file paths

# CI checks
gh pr checks {number}

# List PRs with filters
gh pr list --author @me
gh pr list --label "needs-review"
gh pr list --search "draft:false review:required"

# Actions
gh pr comment {number} --body "text"
gh pr review {number} --approve
gh pr review {number} --request-changes --body "text"
gh pr merge {number} --squash
```

## Pagination

For PRs with many comments, add `--paginate`. Combine with `--jq` to flatten pages:

```sh
gh api --paginate repos/{owner}/{repo}/pulls/{number}/comments --jq '.[]'
```

## Placeholders

Inside `gh api`, `{owner}` and `{repo}` auto-resolve from the current git remote. You can always be explicit: `repos/huntresslabs/portal/pulls/123/comments`.
