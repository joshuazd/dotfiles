# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

A personal workflow automation suite that integrates git worktrees, tmux sessions, Shortcut (task tracker), GitHub PRs, and Claude AI into a unified development workflow. The primary entry points are `dispatch` and the SwiftBar/menu bar plugins.

## Common Commands

```bash
# Run a script directly (they're plain bash/shell executables)
./git-worktree-new feature/my-branch
./git-worktree-session --detached feature/my-branch
./git-worktree-done
./git-worktree-cleanup

# Dispatch a Shortcut story or GitHub PR
./dispatch https://app.shortcut.com/.../story/12345
./dispatch https://github.com/org/repo/pull/123

# Shortcut operations
./shortcut-implement sc-12345
./shortcut-worktree sc-12345
./shortcut-claim sc-12345

# GitHub operations
./gh-worktree 123
./gh-review 123

# Compile the Swift menu bar app
swiftc dispatch-bar.swift -o dispatch-bar
```

There are no build, lint, or test systems for this repo — scripts are run directly and tested manually.

## Architecture

### Shared Library: `common.sh`

All scripts source `common.sh` (via `SCRIPT_DIR` resolution) which provides:
- `info` / `warn` / `error` — colored output helpers
- `help_wanted` — detects `-h`/`--help`/`-?` flags
- `is_git_repo` / `is_in_tmux` — environment checks
- `get_name_from_branch` — strips `feature/`, `bugfix/`, `hotfix/` etc. prefixes
- `extract_story_id` — normalises Shortcut story URL, `sc-<id>`, or bare integer to a numeric ID
- `normalize_pr_input` — strips a leading `#` from a PR number or URL
- `fetch_story_json` — fetches story JSON from Shortcut via the `short` CLI
- `branch_from_json` — extracts `formatted_vcs_branch_name` from story JSON
- `run_worktree_popup` — opens a tmux popup to run `git-worktree-session`; accepts `--detached`, `--non-interactive`, `--prefix <value>`, `--fetch` flags; if `DISPATCH_IN_POPUP=1`, runs inline instead to avoid nested popups
- `resolve_session_script` — locates `git-worktree-session` relative to `SCRIPT_DIR`

### Core Workflow Pipeline

```
dispatch / dispatch-from-chrome / SwiftBar
  → shortcut-implement  (Shortcut story)
  → gh-review           (GitHub PR)
      → run_worktree_popup (common.sh)
          → git-worktree-session
              → git-worktree-new
                  → claude-trust
                  → setup_portal_files (portal repos only)
                  → setup_claude_files (CLAUDE.local.md + .claude symlinks)
```

### Tmux Session Layout

Every session created by `git-worktree-session` has three windows:
- Window 1: main terminal
- Window 2: `server`
- Window 3: `ai` (Claude is launched here by implement/review scripts)

### Worktree Placement

Worktrees are created one level up from the main repo root: `../branch-name`. The directory name is the branch name with its type prefix stripped. The `--prefix` flag prepends a string (e.g., `pr-` for GitHub PRs).

### Portal Repo Detection

`setup_portal_files` in `git-worktree-new` triggers only when `Procfile.dev` exists in the repo root. It symlinks `.env` and `node_modules`, copies generated route files, and creates `Procfile.personal` (port 3001) and `Makefile.local` (skips `docker.up`).

### Claude Integration

`shortcut-implement` and `gh-review` build a prompt from the story/PR context, write it to a temp file, and send it to the `:ai` tmux window via `tmux send-keys`. The `claude-trust` script modifies `~/.claude.json` to pre-trust new worktree directories so Claude doesn't prompt for confirmation.

### dispatch-from-chrome

Gets the active Chrome tab URL via osascript, finds the most recent tmux session, and runs `dispatch` inside a popup with `DISPATCH_IN_POPUP=1`. This prevents nested popups and brings iTerm2 to the foreground after dispatch completes.

### Script Conventions

- All scripts use `set -o errexit -o nounset -o pipefail`
- `readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` at top of each script
- Argument parsing with a `while [ "${#}" -gt 0 ]` / `case` loop
- JSON parsed with `jq` when available, falling back to `grep`+`sed`
- Scripts call `help_wanted "${@}"` before `main` and print usage then exit
