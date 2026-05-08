---
name: commit
description: Use when the user asks to commit, commit and push, or stage and commit changes. Guides through git add, git commit, git fetch, git rebase, and git push with safety checks at each step.
---

# Commit

Step-by-step workflow for committing and pushing changes safely.

## Steps

### 1. Review Changes

Run these in parallel to understand what will be committed:

```bash
git status
git diff
git diff --cached
git log --oneline -5
```

### 2. Stage Files

**Always stage specific files by name** — never `git add -A` or `git add .` (risks staging secrets, binaries, or unintended files).

Announce which files you plan to stage. If it's unclear which files to include, ask.

```bash
git add path/to/file1 path/to/file2
```

### 3. Commit

Draft a message that focuses on the **why** (not just the what). Keep it concise (1–2 sentences).

Write the message to a per-worktree path inside the gitdir, then commit with `-F`:

1. Resolve the path (works in both main repos and worktrees):

   ```bash
   git rev-parse --git-path COMMIT_EDITMSG_AI
   ```

2. Use Write to create that path with content like:

   ```
   Short description of the change

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   ```

3. Commit:

   ```bash
   git commit -F "$(git rev-parse --git-path COMMIT_EDITMSG_AI)"
   ```

(Do not use heredoc — it's blocked by a hook. `git rev-parse --git-path` returns the per-worktree gitdir, so parallel worktrees don't collide.)

**Do NOT:**
- Amend previous commits unless the user explicitly asks
- Skip hooks (`--no-verify`)

### 4. Fetch and Rebase

Always rebase onto main before pushing:

```bash
git fetch origin main
git rebase origin/main
```

If there are conflicts, **stop and alert the user** — ask how to proceed. Do not auto-resolve conflicts.

### 5. Push

Check whether the branch already has a remote tracking branch:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

- **No remote yet:** `git push -u origin HEAD`
- **Already pushed:** `git push --force-with-lease` (safe force-push after rebase)

## Safety Rules

- Never `git push --force` to main/master
- Never skip hooks
- Always `--force-with-lease` (not `--force`) after rebase
- If rebase has conflicts → stop, alert user, ask how to proceed
