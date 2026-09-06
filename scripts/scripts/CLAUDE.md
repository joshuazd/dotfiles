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

```bash
make test   # bats tests/ (tmux interactions run against a stub that records argv)
make lint   # shellcheck over every bash script in the package
```

Both run in CI (`.github/workflows/test-scripts.yml`) on Ubuntu and macOS.

## Architecture

### Shared Libraries: `lib/`

Functions are organized into focused libraries under `lib/`. All scripts source `common.sh` (which loads everything), but individual libs can be sourced directly when only a subset is needed.

- **`lib/output.sh`** — `error` / `info` / `warn`, color codes, `help_wanted`
- **`lib/git.sh`** — `is_git_repo`, `get_name_from_branch`, `extract_story_id`, `normalize_pr_input`, `pr_repo_dir`
- **`lib/shortcut.sh`** — `fetch_story_summary` (returns tab-delimited `title\tbranch` via `short --format`, no JSON parsing)
- **`lib/tmux.sh`** — `is_in_tmux`, `session_name_from_title`, `setup_secondary_pane`, `create_tmux_session`, `launch_claude_in_pane`, `worktree_prompt_file`, `resolve_session_name`, `resolve_session_script`, `run_worktree_popup`, the `SESSION_EXISTED` status

Each lib uses a source guard to prevent double-loading. `common.sh` is a thin shim that sources all four.

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

Every session created by `git-worktree-session` has two windows:
- Window 1: `claude` (Claude is launched here by implement/review scripts)
- Window 2: `server`

### Worktree Placement

Worktrees are created one level up from the main repo root: `../branch-name`. The directory name is the branch name with its type prefix stripped. The `--prefix` flag prepends a string (e.g., `pr-` for GitHub PRs).

**Which repo a review worktree comes from is decided by the PR, not by the caller's directory.** `gh-review` resolves it with `pr_repo_dir`: a PR URL names its repository, so the clone at `${HOME}/<repo>` wins over `$(pwd)`, and a repo with no clone there is a hard error rather than a fall back. Same layout `dispatch-from-chrome` resolves `--repo` against. A bare `gh-review 123` has no repository in its input and keeps using the working directory, which is also what `gh pr view 123` resolves against. This is why vigil's dispatch `cwd` no longer decides anything for a PR: every review dispatched from the vigil queue used to land in whatever repo the pane was in - portal, in practice - because that cwd was the only signal anyone read. `classify_pr` is passed the URL for the same reason: a bare number would classify the same-numbered PR in the caller's repo.

### Portal Repo Detection

`setup_portal_files` in `git-worktree-new` triggers only when `Procfile.dev` exists in the repo root. It symlinks `.env` and `node_modules`, copies generated route files, and creates `Procfile.personal` (port 3001) and `Makefile.local` (skips `docker.up`).

### Claude Integration

`shortcut-implement` and `gh-review` build a `claude` command from the story/PR context and make it the `:claude` pane's own process with `tmux respawn-pane -k` (`launch_claude_in_pane`), not text typed in with `send-keys`: there is no shell-readiness race and the command never passes through a shell prompt. The command appends `; exec "${SHELL}"` so exiting Claude leaves a usable pane.

The multi-line system prompt travels via a file rather than the command line: `worktree_prompt_file` puts it at `vigil-launch-prompt.txt` inside the worktree's private git dir (so it never shows in `git status` and goes away with the worktree), and the command reads it back with `--append-system-prompt "$(cat <file>)"`.

Re-dispatching a story or PR that already has a session must not relaunch Claude - `respawn-pane -k` would SIGKILL the Claude running there. `create_tmux_session` returns `SESSION_EXISTED`, `git-worktree-session` and `run_worktree_popup` carry that status out through the popup, and both callers skip the launch and just switch to the live session.

The `claude-trust` script modifies `~/.claude.json` to pre-trust new worktree directories so Claude doesn't prompt for confirmation.

### Read-Only Review Sessions

A review reads; it never publishes. `gh-review` therefore launches with `--permission-mode bypassPermissions`, so a review never stops to ask, and with `CLAUDE_READONLY_REMOTE=1`, which arms the `block-remote-writes.sh` PreToolUse hook in `claude/.claude/hooks`. Hooks still run under a bypassed permission mode, so that hook - not the permission system - is what denies `git push`, remote-mutating `gh`/`short` calls, and Slack posts in these sessions. It is an allowlist: an unrecognised `gh` subcommand is denied. The pairing is load-bearing in both directions, and `tests/gh_review.bats` asserts both flags travel together; the hook's own bats suite lives beside it.

No other launcher sets the variable, so `shortcut-implement` sessions keep the normal permission prompts and can still push.

### dispatch-from-chrome

Gets the active Chrome tab URL via osascript, validates it looks like a Shortcut story or GitHub PR, brings a tmux client to the front (attaching one via iTerm2 if none exists, so the job's closing `switch-client` has somewhere to land), then hands the URL straight to `vigil dispatch`, which submits it to vigild. No popup is opened here.

### Worktree Removal Is Gated

`git-worktree-done` (bound to `prefix d`) and `wt-pick remove` both destroy a
worktree and a tmux session. Both go through `wt-confirm`, which is the only
gate — do not add a third path that skips it, and a gate that cannot be found
is a hard error rather than a silent proceed.

`wt-confirm` renders inline when it has a tty and opens its own popup when it
does not. That branch is load-bearing: `prefix d` runs under `run-shell -b`
with no tty, while `wt-pick` is already inside the menu's popup, and a NESTED
`display-popup` has no client to draw on, so fzf exits 0 printing nothing and
the answer is silently lost. `tmux display-popup -E` also does not return the
popup command's exit status, which is why the popup pass communicates through
an answer file.

Cancel is the first row, so it is the cursor position and the Enter answer.

### Menus

`fzf-menu` runs `menus/<name>.menu`, a tab-separated `Label<TAB>command`
table. Sigils say where a command runs: none (in the popup, pausing for a
key), `@window`, `@pane`, `@bg`, `@menu`.

**Dynamic lists are scripts, not menu syntax.** `wt-pick`, `pr-pick` and
`sc-pick` each take a verb and call `pick_one` themselves; because `fzf-menu`
renders inline (`--size ""`), that second picker draws in the same popup as a
second screen. Keeping pipelines out of the `.menu` files is the whole reason
the format is worth having.

Sibling scripts are dispatched by absolute path through `PKG_DIR`, overridable
with `SCRIPTS_PKG_DIR` — that override is how the tests point them at
recorders, since a PATH stub cannot intercept an absolute path.

`lib/menu.sh` owns every `display-menu` invocation the way `lib/picker.sh`
owns fzf's. `menu_or_pick` is the single decision point; nothing else should
be choosing a backend.

`MENU_CHROME_ROWS` is deliberately generous and must only be lowered against a
measurement. Too large costs an early fzf fallback; too small means tmux
silently draws nothing, which reads as a broken keybinding. It cannot be
measured headlessly - see `tests/manual/verify-menu-chrome.md` for the two
approaches that fail and why.

Values crossing into a menu item's `run-shell` command are escaped twice:
`printf '%q'` for the shell and `menu_tmux_quote` for tmux's own parser.
Dropping either makes a path with a space act on its first word. Assertions
about these commands must expect the ESCAPED form - checking for the plain
text is checking for the bug.

`popup()` sizes the tmux popup to the tallest screen a menu can reach,
including one level of `@menu` target. `POPUP_CHROME_ROWS` is **measured, not
derived** (`tests/manual/verify-menu-fit`); do not adjust it by estimation.

### What The Menu Actions Do

The menu labels are short; the side effects are not. Read this before adding
or reaching for an entry.

**shortcut.menu**

| Entry | Side effects |
|---|---|
| Claim a story | **Mutates the story.** Adds you as an owner through the API |
| Implement a story | Full dispatch: creates a worktree at `../branch-name`, creates a tmux session with `claude` and `server` windows, launches Claude in plan mode seeded with the story, and switches you to it |
| Worktree from a story | Worktree and session as above. No Claude |
| Open a story in browser | Read-only (`short story <id> -O`) |
| Story from this branch | Read-only |

**pr.menu**

| Entry | Side effects |
|---|---|
| Checkout PR as worktree | Fetches the branch, creates worktree and session, switches you there |
| Review PR with Claude | As above, plus Claude with the review prompt under `bypassPermissions` and `CLAUDE_READONLY_REMOTE=1`, so the `block-remote-writes.sh` hook denies pushes |
| Open in browser / Diff a PR / Checks | Read-only |
| Create PR | New window, interactive `gh pr create`. **Publishes** once you complete it |

**worktree.menu**

| Entry | Side effects |
|---|---|
| Switch worktree | `ts` attaches **or creates** a session and switches you there |
| Remove a worktree | Gated. Kills the session, moves the directory aside and deletes it, prunes, drops mise tracked-config symlinks, stops the rubocop server |
| New worktree | Creates `../branch-name`, runs `claude-trust` and the portal / `CLAUDE.local.md` setup. No session |
| Done (this worktree) | Gated. The same destruction, for the worktree you are in |

**tmux.menu** is local tmux state and reversible, except: `Clear this pane
history` discards scrollback, and `Respawn this pane` kills the pane's running
process, which is why it goes through a confirmation.

### Script Conventions

- All scripts use `set -o errexit -o nounset -o pipefail`
- `readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` at top of each script
- Argument parsing with a `while [ "${#}" -gt 0 ]` / `case` loop
- JSON parsed with `jq` when available, falling back to `grep`+`sed`
- Scripts call `help_wanted ${1+"${@}"}` before `main` and print usage then exit.
  **The `${1+...}` is load-bearing and applies to every top-level `"${@}"`.**
  `/bin/bash` is 3.2 on a stock macOS and on the macos-latest runner, and there
  `"${@}"` with no positional parameters is an unbound variable under
  `set -o nounset` rather than an empty list. Without it every one of these
  scripts aborted with `@: unbound variable` on a no-argument run instead of
  printing usage, and `vigil-panel` - bound to `prefix p`, which passes no
  arguments at all - never worked on such a machine. The same applies after a
  `shift` leaves nothing, which is why `lib/route.sh`'s `extra_flags` uses it
