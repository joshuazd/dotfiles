---
name: create-pr
description: This skill should be used whenever creating a GitHub pull request. Provides conventions for PR creation including draft status, template usage, and labeling.
version: 1.0.0
---

# Create PR

## Steps

### 1. Commit changes

If there are uncommitted changes, invoke the `commit` skill to stage and commit them. Do not re-implement the commit flow here.

### 2. Resolve default branch

The default branch is not always `main`. Resolve it once and reuse:

```bash
default_branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
```

Use `$default_branch` (or `origin/$default_branch`) in the steps below.

### 3. Analyze Branch Changes

```bash
git log "origin/$default_branch"..HEAD --oneline
git diff "origin/$default_branch"..HEAD --stat
git diff "origin/$default_branch"..HEAD
```

Use this information to:
- Determine PR type (e.g., feature, bug, chore)
- Identify if migrations exist
- Identify if tests were added/updated

### 4. Fetch and Rebase

```bash
git fetch origin "$default_branch" && git rebase "origin/$default_branch"
```

If there are merge conflicts, inform the user and ask how to proceed.

### 5. Push to Remote

If the branch has not been pushed before:

```bash
git push -u origin HEAD
```

If it has been pushed and step 4 rewrote history, use `--force-with-lease` (never plain `--force`):

```bash
git push --force-with-lease origin HEAD
```

Check with `git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null` — if it returns an upstream, the branch was pushed before.

### 6. Create Draft PR

Use `gh pr create --draft` with these requirements.

#### PR Title
- Derive from the user's initial request or context
- If unclear, derive from branch name or changes
- Format: Human-readable, concise description
- Do NOT include shortcut story ID

#### PR Body

The body must use the template from `.github/pull_request_template.md` if it exists. If no template exists, use a minimal body with just the Description section.

**Template usage:**
- Preserve ALL checklist items — never delete or omit `- [ ]` items
- Preserve section headers — never delete lines starting with `##`
- Preserve structure — never rearrange sections
- Fill in **only the Description section**. Do NOT check any boxes (including Type), do NOT fill any other fields. Reviewers handle those.

**Description content** (1–2 sentences, facts only):
- User-facing changes if present (new features, bug fixes, UI); otherwise internal changes (refactors, optimizations)
- Describe conceptually — never mention filenames
- If a Shortcut story is linked, include the story link/ID in the appropriate template field (typically a "Story" or "Ticket" field). If no such field exists in the template, append the link to the Description.
- No customer impact statements, no value props, no marketing language, no "Generated with Claude Code" footer

**Body delivery** (avoid heredoc per global preferences): generate a unique temp path with `mktemp` (never hardcode `/tmp/pr_body.md` — parallel Claude instances will clobber each other), write the body with the Write tool, then pass it via `--body-file`:

```bash
pr_body_file=$(mktemp "${TMPDIR:-/tmp}/pr_body.XXXXXX") && echo "$pr_body_file"
# Write tool writes the body to the absolute path printed above
gh pr create --draft --title "..." --body-file "$pr_body_file" [labels...]
rm -f "$pr_body_file"
```

## Conventions

- Always create **draft** PRs (`gh pr create --draft`)
- Use the repo's PR template if one exists; otherwise use a minimal body
- Add a description only — do NOT check any boxes (including Type), fill in any checklists, or modify any other fields
- Always add the `ai-assisted` label (`--label "ai-assisted"`)
- If the repo is `huntresslabs/portal` (check with `gh repo view --json nameWithOwner -q .nameWithOwner`):
  - Always add `--label "TEAM: SOC"`
  - Add `--label "SOC Agentic"` **only if the work is agentic-related** (touches agent code, agent eval fixtures, agent prompts/tools, or otherwise scoped to agentic features). If unclear from the diff, ask the user.
