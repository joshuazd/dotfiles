---
name: approve-pr
description: Approve a GitHub pull request, optionally with a comment body.
disable-model-invocation: true
---

# Approve PR

Approve a GitHub PR. Optional comment passed as args.

## Usage

- `/approve-pr` — approve the current branch's PR with no comment
- `/approve-pr 123` — approve PR #123 with no comment
- `/approve-pr LGTM!` — approve current branch's PR with comment "LGTM!"
- `/approve-pr 123 Looks great, ship it` — approve PR #123 with comment

## Steps

1. **Parse args**: If first arg is a number, treat it as the PR number; everything after is the comment body. If first arg is not a number, everything is the comment body and use the current branch's PR.

2. **Approve**:
   - With comment: `gh pr review <number> --approve --body "<comment>"`
   - Without comment: `gh pr review <number> --approve`

3. **Confirm** by printing the result.
