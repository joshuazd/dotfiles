---
name: create-pr
description: This skill should be used whenever creating a GitHub pull request. Provides conventions for PR creation including draft status, template usage, and labeling.
version: 1.0.0
---

# Create PR

## Steps

### 1. Commit changes

Check for uncommitted changes, stage relevant changes, and commit them with a descriptive message.

```bash
git commit -m "Your descriptive commit message here"
```

### 2. Analyze Branch Changes

Run these commands to analyze the changes in the current branch compared to the main branch:

```bash
git log origin/main..HEAD --oneline
git diff origin/main..HEAD --stat
git diff origin/main..HEAD
```

Use this information to:
- Determine PR type (e.g., feature, bug, chore)
- Identify if migrations exist
- Identify if tests were added/updated

### 3. Fetch and Rebase from main

Before creating a PR, ensure your branch is up to date with the main branch:

```bash
git fetch origin main && git rebase origin/main
```

If there are merge conflicts, inform the user and ask how to proceed.

### 4. Push to Remote

After rebasing, push your changes to the remote repository:

```bash
git push origin HEAD
```

### 5. Create Draft PR

Use `gh pr create` with these requirements:

#### PR Title:
- Derive from the user's initial request or context
- If unclear, derive from branch name or changes
- Format: Human-readable, concise description
- Do NOT include shortcut story ID

#### PR Body:

The body must use the template from `.github/pull_request_template.md` if it exists.

##### Template Usage:
- Preserve ALL checklist items --never delete or omit and `- [ ]` items
- Preserve section headers --never delete or omit lines starting with `##`
- Preserve structure --never rearrange sections or checklists
- Only fill in Description --add content in the Description section, leaving all other sections and checklists empty

##### Description section
Write 1-2 sentences maximum describing WHAT changed (facts only):
- Focus on user-facing changes if present (new features, bug fixes, UI changes)
- Otherwise, describe internal changes (refactors, optimizations, etc.)
- Never mention filenames, describe what changed conceptually
- Be direct and technical

Tone Requirements:
- NO customer impact statements
- NO value propositions or marketing language
- NO signature or "Generated with Claude Code" footer
- Just state the facts

##### Type Checkbox
Automatically check ONE of these based on the changes:
- `- [x] Feature` if new functionality was added
- `- [x] Bug` if a bug was fixed
- `- [x] Chore` if the change is a non-feature, non-bugfix task (e.g., refactor, test update, documentation)

## Conventions

- Always create **draft** PRs (`gh pr create --draft`)
- Use the repo's PR template if one exists
- Add a description only — do NOT check any boxes, fill in any checklists, or modify any other fields in the template
- Always add the `ai-assisted` label (`--label "ai-assisted"`)
- If the repo's git remote is `portal` (check with `gh repo view --json name -q .name`), also add `--label "TEAM: SOC" --label "SOC Copilot"`
