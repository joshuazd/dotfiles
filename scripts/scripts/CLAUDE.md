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
- **`lib/vigil.sh`** — `resolve_vigil`, which finds the binary even when `~/.local/bin` is not on PATH (menu bar app, tmux `run-shell`)

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

**A failed dispatch takes its own worktree with it.** Left behind, it blocks every retry: `git-worktree-new` refuses the directory, a stale registration still holds the branch once the directory is gone, and a surviving session makes the retry report `SESSION_EXISTED` and skip the launch. `worktree_rollback_arm` (`lib/worktree.sh`) sets an EXIT trap that runs `git-worktree-cleanup` on a nonzero exit, and `worktree_rollback_disarm` clears it. It is armed twice, once per process that creates something: `git-worktree-session` arms before `git-worktree-new` and disarms once the session exists, and `gh-review` / `shortcut-implement` arm after a status-0 popup and disarm once Claude is launched. Only ever for what this run created. A directory or session that was already there is someone else's. Rollback output goes to the cleanup log, so the run's real error stays the last line vigil shows.

`create_tmux_session` returns 1 explicitly from `new-session`, `set-option` and `new-window`. Every caller runs it under `||`, which turns errexit off for the whole body, so without the explicit returns a session tmux created under a different name failed every step and still reported success. A title ending in `;` did exactly that, because tmux reads a trailing `;` in argv as a command separator. That is why `session_name_from_title` strips semicolons.

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

**The caller hands the gate an action, and never reads an answer back.**
`wt-confirm --run <command>` is the only shape. The confirming menu item *is*
`run-shell -b <command>`, exactly as tmux writes its own confirmations
(`Yes y { kill-pane }`).

This is not stylistic. **`tmux display-menu` cannot be relied on to block until
its menu is answered.** Measured from a menu item's `run-shell -b`: it returned
0 one second after opening, with the menu still on screen and untouched. A gate
that read an answer variable afterwards therefore always read the seeded
default, reported a cancel, and exited - and the eventual keypress landed on a
menu nobody was listening to, which looked exactly like a confirm that did
nothing. A separate harness DID see it block, which is why this must not be
rebuilt on that behaviour no matter what a local experiment shows.

Consequences worth keeping straight:

- Every caller supplies a re-entry point for its own post-confirm work:
  `wt-pick --cleanup <path>` and `git-worktree-done --confirmed <path>
  <session>`. Neither is a verb, because nothing may reach them without
  passing the gate first.
- The `--confirmed` re-entry is TOLD its worktree and session rather than
  recomputing them. It runs under a menu item's `run-shell -b`, by which point
  the focused pane is whatever the user is looking at, not necessarily the
  worktree the menu named.
- **The cleanup gets no popup and no output surface, on either path.**
  Removing a worktree is fire-and-forget: the confirmation already happened
  and the session leaving vigil's list is the feedback. `prefix d` must stay
  one keypress, one question, no boxes.

  Both popups here were removed for this. `wt-pick`'s was added and taken out
  the same week, reasoned from "`run-shell` output is invisible behind an
  alternate screen" - true, and beside the point, because nobody reads cleanup
  output. `git-worktree-done`'s dated to 2026-03-02 and was defended in a
  comment about the legibility of scrolling output, which is worth nothing
  against a box appearing after every removal. `tests/git_worktree_done.bats`
  guards the whole path, not just the line that was deleted.

  Output goes to `~/.cache/worktree-cleanup.log` via `worktree_run_cleanup`,
  not to stdout. `run-shell -b` writes stdout into the focused pane, and after
  `prefix d` the switch has already landed the user in a DIFFERENT session, so
  the removal reported itself into a pane with nothing to do with it. Nowhere
  on screen, but not `/dev/null` either: a refusal has to leave a trace
  somewhere findable. `WORKTREE_CLEANUP_LOG` overrides the path, which is how
  the tests read it.

  So a cleanup that refuses - a dirty worktree, a missing directory - is
  silent at the time and findable afterwards. That is the intended trade.
  Do not "fix" it with a popup.

`wt-confirm` still renders inline with fzf when it has a tty, and opens its own
popup when it can draw neither. That branch is load-bearing: `wt-pick` on the
fzf fallback is already inside the picker's popup, and both a `display-menu`
and a NESTED `display-popup` asked for over a popup return 0 without drawing.
On the inline path the gate runs the command itself.

Cancel is the first row, so it is the cursor position and the Enter answer, and
it carries no command at all. Escape and `q` dismiss a `display-menu` without
running any item, so they cancel for free.

### Menus

`fzf-menu` runs `menus/<name>.menu`, a tab-separated `Label<TAB>command`
table. Sigils say where a command runs: none (in the popup, pausing for a
key), `@window`, `@pane`, `@bg`, `@menu`.

**Dynamic lists are scripts, not menu syntax.** `wt-pick`, `pr-pick` and
`sc-pick` each take a verb and call `pick_one` themselves; because `fzf-menu`
renders inline (`--size ""`), that second picker draws in the same popup as a
second screen. Keeping pipelines out of the `.menu` files is the whole reason
the format is worth having.

**Typed input is a script too, for the same reason and one more.** A `.menu`
row is a fixed command string, so an entry whose command needs a value the user
has to type cannot be written as one: `@window git-worktree-new` ran the creator
with no branch name, which exits 1 on the missing argument and takes its own
window down with the error still in it - a menu entry that visibly does
nothing. `wt-new` asks instead.

**Where it asks is decided by whether it has a tty**, the same split
`tmux-respawn` makes for its confirmation:

- **No tty** - a `@quiet` entry under `run-shell`, which is the normal menu
  path. Ask with `tmux command-prompt`: one line on the status bar, and the
  only overlay that can draw with no popup up.
- **A tty** - the fzf fallback, or a plain shell. Read it right there. The
  fallback path is already inside the picker's popup, where a `command-prompt`
  would not draw at all.
- **Neither** - read stdin, for `printf name | wt-new` and for the tests.

A bare entry looks tempting, because the bare case is the one that gets a tty
on both backends. It is wrong: that tty is fzf-menu's 80%x60% *output* popup,
which is an enormous box to hold one short question - the first version of this
shipped that way and the box was the complaint. The output popup is still where
the creation runs, opened by `--act` once there is output to put in it.

**`command-prompt` cannot return an answer**, only substitute it into a tmux
command, so the answer comes back through a `--act` re-entry point - the same
shape `wt-confirm` has with `display-menu`, and for the same reason. Two
consequences:

- **The answer travels in a tmux option** (`@wt_new_branch`), not in the text of
  the `run-shell` that `--act` runs. `%%` is substituted before anything parses
  the template, so a branch name interpolated into that command would be read by
  the *shell*, with no way to escape it from this side. In an option it is seen
  by tmux's parser alone. `--act` clears the option as it reads it, so a later
  one cannot act on a stale answer.
- **`--act` is told its repository**, resolved when the prompt was opened. By
  the time an answer arrives the focused pane is whatever the user is looking
  at, which need not be the repository they asked from. Same reason
  `git-worktree-done --confirmed` is told its worktree.

Sibling scripts are dispatched by absolute path through `PKG_DIR`, overridable
with `SCRIPTS_PKG_DIR` — that override is how the tests point them at
recorders, since a PATH stub cannot intercept an absolute path.

`lib/menu.sh` owns every `display-menu` invocation the way `lib/picker.sh`
owns fzf's. `menu_or_pick` is the single decision point; nothing else should
be choosing a backend.

**Mnemonic keys.** A `&` in a label marks its key: `&Fetch and prune` binds
`f`, `Res&pawn this pane` binds `p`. The key lives inside the label so it
cannot drift from the text it abbreviates, and the format stays two fields.
Keys are folded to LOWERCASE - labels are title case, so taking the marked
character as written would bind Shift-F. Only the first marker is stripped, so
a trailing `&` is left alone and is not a mnemonic.

A label with no marker falls back to its position as a digit, which is what
the pickers rely on: worktree paths and PR titles have no stable text to be
mnemonic about. fzf has no key column, so `menu_rows_numbered` strips the
marker and prefixes the digit for that path only; the same entry is `s`
natively and `2` in the fallback.

**Picker labels are never parsed for markers.** `menu_or_pick` renders its
rows with `menu_show ... literal`: every item keyed by position, `&` left as
text, `#` doubled past tmux's format expansion. A PR titled `haml-rails & haml`
used to bind Space.

A label beginning with `-` is an information row: tmux draws it dim and
refuses to select it, ignoring its key entirely. That is what lets the confirm
menus carry a path, a branch and a risk summary above the choices.

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
| Implement a story | Submits the `sc-<id>` to `vigil dispatch`, like `dispatch-from-chrome`: vigild runs `shortcut-implement` as a job (worktree at `../branch-name` cut from the current directory's repo, `claude` / `server` session, Claude in plan mode seeded with the story) and switches you there when it lands. No popup |
| Worktree from a story | Worktree and session as above. No Claude |
| Open a story in browser | Read-only (`short story <id> -O`) |
| Story from this branch | Read-only |

**pr.menu**

| Entry | Side effects |
|---|---|
| Checkout PR as worktree | Fetches the branch, creates worktree and session, switches you there |
| Review PR with Claude | Submits the PR URL to `vigil dispatch`, like `dispatch-from-chrome`: vigild runs `gh-review` as a job (worktree, session, Claude under `bypassPermissions` and `CLAUDE_READONLY_REMOTE=1` so the `block-remote-writes.sh` hook denies pushes) and switches you there when it lands. No popup |
| Open in browser / Diff a PR / Checks | Read-only |
| Create PR | New window, interactive `gh pr create`. **Publishes** once you complete it |

**worktree.menu**

| Entry | Side effects |
|---|---|
| Switch worktree | `ts` attaches **or creates** a session and switches you there |
| Remove a worktree | Gated. Kills the session, moves the directory aside and deletes it, prunes, drops mise tracked-config symlinks, stops the rubocop server |
| New worktree + session | Asks for a branch name, then `wt-new --session`: the worktree, a `claude` / `server` session, and a switch to it. No Claude |
| New worktree only | Asks for a branch name, then `wt-new`: creates `../branch-name`, runs `claude-trust` and the portal / `CLAUDE.local.md` setup. No session |
| Done (this worktree) | Gated. The same destruction, for the worktree you are in |

Both new-worktree rows take the branch name from a status-bar prompt and do
the creation in a popup afterwards - see **Typed input is a script too** above.
The `--session` half is `run_worktree_popup`, which creates the session
`--detached` and switches the client after its popup closes, because a session
has to exist before a client can be moved onto it. It is the only
arbitrary-branch worktree+session entry in any menu: every other
session-creating row is keyed to a story or a PR.

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
