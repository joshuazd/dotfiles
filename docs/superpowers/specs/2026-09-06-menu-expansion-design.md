# Menu Expansion Design

**Date:** 2026-09-06
**Status:** Approved
**Builds on:** `docs/superpowers/specs/2026-09-04-fzf-picker-framework-design.md`

## Goal

Extend the fzf picker framework from one menu to six, add the dynamic
(list-then-act) pickers the new menus need, and put a confirmation gate in
front of the one action in this dotfiles repo that destroys work without
asking.

## Background

The framework shipped with three tiers:

1. `lib/picker.sh` — `pick_one` / `pick_many`, the only place that owns fzf argv
2. `fzf-menu` — a runner over declarative `menus/*.menu` files
3. bespoke pickers — scripts that call `pick_one` directly

Only tier 1, tier 2, and a single `git.menu` exist. Tier 3 has no instances.

A `.menu` file is a tab-separated `Label<TAB>command` table whose command may
carry a leading sigil naming *where* it runs: none (in the popup, pausing for
a keypress), `@window`, `@pane`, `@bg`.

### Rejected: an `@from` sigil

The first design for dynamic menus added `@from <list-cmd> ::: <action-cmd>`
with fzf-style `{}` substitution. It was rejected, and the reasoning is
recorded here because the idea will come back.

A `.menu` file earns its format by being readable at a glance — every row is
`Label → verb`. `@from` puts shell pipelines, a `:::` separator, and field
tokens into that table, and the readability goes away:

```
Switch worktree	@from git worktree list --porcelain | awk '/^worktree /{print $2}' ::: @pane cd {}
```

It also fails on the cases that motivated it. Worktrees, PRs, and Shortcut
stories each need column formatting, an empty-list message, and a preview.
None of that fits on one line, so each would need a script anyway — leaving
two mechanisms where one would do. Finally, `@from` breaks `popup()`, which
sizes the tmux popup by counting rows in the file; a generated row count is
not knowable until a command runs.

Tier 3 already answers the need. Because `fzf-menu` renders fzf inline
(`--size ""`), a tier-3 script calling `pick_one` from a menu action draws in
the *same* popup — a second screen, not a nested popup.

## Non-Goals

- Repo-local `.menu` discovery
- Recursive menu chaining beyond one level
- Replacing the existing single-key bindings (`v`/`p` vigil, `u` portal,
  `d` worktree-done) with menu entries. Those are muscle memory; routing a
  keypress through a picker is strictly slower. Menus earn their keep on
  actions you *forget*, not actions you *do*.
- Expanding `git.menu`. There are ~150 git aliases; the menu's value is the
  handful with awkward syntax, not coverage.

## Global Constraints

- `bash` 3.2 compatible — stock `/bin/bash` on macOS and on the
  `macos-latest` CI runner. Notably `${1+"${@}"}` for a possibly-empty argv
  under `set -o nounset`.
- `shellcheck` clean.
- `set -o errexit -o nounset -o pipefail` in every script.
- Every new script gets the repo's standard header comment block
  (`name - one line`, `Usage:`, `Arguments:`, `Example:`) and `help_wanted`
  handling, matching the existing scripts in `scripts/scripts/`.
- Google Shell Style function comment blocks, as used throughout
  `scripts/scripts/`.
- `lib/picker.sh` remains the only file that constructs fzf argv. Tier-3
  scripts pass options to `pick_one`; they never invoke `fzf`.
- Tests are bats, run by `scripts/scripts/Makefile`, using the existing
  argv-recording stub in `tests/stubs/`.
- No em dashes in user-facing strings or documentation.

## Part A — Framework Changes

### A1. The `@menu` sigil

```
Worktrees	@menu worktree
```

Runs `fzf-menu <name>` inline, in the current popup, with no trailing
keypress pause. It exists so `menu.menu` can chain into the other five.

Implementation lands in the two existing sigil functions and `run_action`:

- `action_sigil` returns `menu` for `@menu `
- `action_body` strips the sigil
- `run_action`'s `menu` branch `exec`s `fzf-menu <body>`

`exec` rather than a subshell: the parent has nothing left to do, and
replacing the process keeps the popup's exit status the target menu's own.

`explain_action` describes it as the menu it opens.

**Depth:** one level. `menu.menu` may reference the five leaf menus; a leaf
menu must not carry an `@menu` row. This is a convention enforced by
`popup()`'s sizing (below) rather than a runtime check — a second level would
size wrong, and no menu needs one.

### A2. `popup()` sizing across `@menu`

`popup()` currently counts a menu's rows to compute a height. A menu that
chains must be sized for whichever screen is tallest, or the target menu
scrolls inside a popup built for its parent.

New rule: height is driven by the maximum of the menu's own row count and the
row count of each `@menu` target it names, still clamped to
`POPUP_MAX_ITEMS` and still adding `POPUP_CHROME_ROWS`.

`POPUP_CHROME_ROWS` is unchanged and must stay unchanged — it was measured,
not derived, by `tests/manual/verify-menu-fit`, and an estimate one row short
made every menu scroll.

### A3. `pick_one --empty-message`

With empty input, fzf exits 1, `pick_one` maps that to
`PICKER_NO_SELECTION`, and `fzf-menu` treats it as a successful no-op — so
the popup closes instantly with no explanation. "No open PRs" and "No other
worktrees" are the common cases in the new menus.

`--empty-message <text>` makes `pick_one` detect empty input before invoking
fzf, print the message to stderr, and return `PICKER_NO_SELECTION`. Without
the option the behavior is exactly as it is today.

Detecting empty input requires reading stdin before fzf sees it, so
`pick_one` buffers its input when (and only when) `--empty-message` is set.

## Part B — Tier-3 Domain Pickers

Three scripts in `scripts/scripts/`, each taking a verb so that menu rows
stay one line and one idea:

### B1. `wt-pick <switch|remove>`

Lists worktrees from `git worktree list --porcelain`, excluding the main
repository (`git_dir == git_common_dir`) and the current worktree. Rows show
the directory basename and its branch.

- `switch` — `ts <dir>`, which attaches or creates the session
- `remove` — routes through the Part D confirmation gate, then
  `git-worktree-cleanup <dir>`

Empty message: `No other worktrees.`

### B2. `pr-pick <checkout|review|browse|diff>`

Lists open PRs via `gh pr list --json number,title,headRefName`. Rows show
number, title, and branch.

- `checkout` — `gh-worktree <number>`
- `review` — `gh-review <number>`
- `browse` — `gh pr view --web <number>`
- `diff` — `gh pr diff <number>` paged

Empty message: `No open PRs.`

### B3. `sc-pick <claim|implement|worktree|browse>`

Lists the user's unfinished Shortcut stories. The listing command is
**verified live against the CLI**:

```sh
short s -q 'owner:%self% !is:done' -f '%j' \
  | jq -r '"sc-\(.id)\t\(.state.name // "?")\t\(.name)"'
```

`-f '%j'` emits pretty-printed JSON objects back to back, not JSONL; `jq`
consumes that stream without `-s`. Rows are story ID, workflow state, name.

- `claim` — `shortcut-claim <id>`
- `implement` — `shortcut-implement <id>`
- `worktree` — `shortcut-worktree <id>`
- `browse` — `short story <id> -O`

Empty message: `No stories assigned to you.`

Note that `short story -o` *assigns* owners; only `short s -o` filters, and
the two must not be confused. `sc-pick` uses neither — the `owner:%self%`
search operator does the filtering server-side.

`short story <id> -O` opens in a browser and does not modify the story.

### Shared shape

All three:

- reject an unknown verb with a usage error and exit 2
- pass `--empty-message` to `pick_one`
- return 0 when the user escapes
- are runnable from a plain shell, not only from a menu

## Part C — Menu Files

### `worktree.menu`
```
# Worktree actions
Switch worktree	wt-pick switch
Remove a worktree	wt-pick remove
New worktree	@window git-worktree-new
Done (this worktree)	git-worktree-done
```

### `pr.menu`
```
# Pull request actions
Checkout PR as worktree	pr-pick checkout
Review PR with Claude	pr-pick review
Open PR in browser	pr-pick browse
Diff a PR	pr-pick diff
Checks for this branch	gh pr checks
Create PR	@window gh pr create
```

### `tmux.menu`
```
# Tmux actions
Toggle synchronize-panes	@bg tmux set -w synchronize-panes
Rename this window	@bg tmux command-prompt -I "#W" "rename-window -- '%%'"
Move window to session	@bg tmux command-prompt -p "session:" "move-window -t '%%'"
Clear this pane's history	@bg tmux clear-history
Respawn this pane	@bg tmux respawn-pane -k
Reload tmux.conf	@bg tmux source-file ~/.tmux.conf
```

`@bg` rather than a bare command: each is a tmux control operation that must
outlive the popup, and none produces output worth pausing for. `tmux
command-prompt` in particular cannot run inside the popup that is about to
close.

`Kill other sessions` was considered and cut — it is exactly the class of
irreversible action this change is otherwise adding a gate to.

### `shortcut.menu`
```
# Shortcut actions
Claim a story	sc-pick claim
Implement a story	sc-pick implement
Worktree from a story	sc-pick worktree
Open a story in browser	sc-pick browse
Story from this branch	short story --from-git
```

### `menu.menu`
```
# Menus
Git	@menu git
Worktree	@menu worktree
Pull requests	@menu pr
Tmux	@menu tmux
Shortcut	@menu shortcut
```

## Part D — The Worktree-Done Confirmation Gate

### The problem

`prefix d` runs `git-worktree-done`, which switches to the most recent other
session and opens a popup running `git-worktree-cleanup`. `git-worktree-cleanup`
kills the tmux session and `mv`s the worktree aside immediately. **There is no
confirmation anywhere in that path**, and a mistyped `prefix d` destroys a
session and a working tree.

### The gate

A confirmation step inside `git-worktree-done`, before `switch-client`, so
both entry points (`prefix d` and `worktree.menu`) pass through it and
neither can bypass it.

Where it draws depends on whether it already has somewhere to draw:

- Called from `git-worktree-done` under `prefix d`, there is no tty — the
  binding is `run-shell -b` — so the gate opens its own `display-popup` and
  re-enters itself inside it.
- Called from `wt-pick remove`, the caller is *already* running inside the
  menu's popup and has a tty. The gate renders inline. It must not open a
  popup here: a nested `display-popup` has no client to draw on, fzf exits 0
  printing nothing, and the selection is silently lost — the same failure the
  framework documents for nested pickers.

So the gate branches on `[ -t 0 ]`, matching the convention `run_action`
already uses for its keypress pause.

It presents, via `pick_one`:

```
Remove worktree SC-1234-fix-thing?
  ~/code/SC-1234-fix-thing  (branch sc-1234-fix-thing)
  3 uncommitted files, 2 unpushed commits

  Cancel
  Remove worktree and kill session
```

- Cancel is first, so it is the default cursor position and the Enter-key
  answer
- Escape means cancel
- Uncommitted count: `git status --porcelain | wc -l`
- Unpushed count: `git rev-list --count @{upstream}..HEAD`, treated as
  "no upstream" when that fails rather than as an error

The counts are the point. A clean, pushed worktree is cheap to recreate; the
cost of an accidental removal is entirely in what those two numbers report.

`wt-pick remove` calls the same gate for a worktree that is not the current
one.

### Refactoring note

The gate is shared between `git-worktree-done` and `wt-pick`, so it lives in
one place. `scripts/scripts/common.sh` already exists and is sourced by both
worktree scripts; the gate function goes there.

## Part E — Keybindings

In `tmux/.tmux.conf`:

```tmux
bind-key w   run-shell -b "$HOME/scripts/fzf-menu --popup worktree"
bind-key C-w run-shell -b "$HOME/scripts/fzf-menu --popup worktree"
bind-key r   run-shell -b "$HOME/scripts/fzf-menu --popup pr"
bind-key C-r run-shell -b "$HOME/scripts/fzf-menu --popup pr"
bind-key t   run-shell -b "$HOME/scripts/fzf-menu --popup tmux"
bind-key C-t run-shell -b "$HOME/scripts/fzf-menu --popup tmux"
bind-key s   run-shell -b "$HOME/scripts/fzf-menu --popup shortcut"
bind-key C-s run-shell -b "$HOME/scripts/fzf-menu --popup shortcut"
bind-key m   run-shell -b "$HOME/scripts/fzf-menu --popup menu"
```

Matching the existing `g`/`C-g` pattern.

**`prefix m` gets no `C-m` variant.** Terminals transmit `C-m` as carriage
return, so binding it would rebind `prefix Enter`.

`t` and `s` displace tmux's default `clock-mode` and `choose-tree`.
`choose-tree` is already on `f`/`C-f`; `clock-mode` is not otherwise bound
and is not missed.

`tmux-resurrect` binds `prefix C-s` (save) and `prefix C-r` (restore) by
default, which collides with both `shortcut` and `pr`. It moves to Shift
keys via its documented options, before the plugin's `run-shell` line:

```tmux
set -g @resurrect-save 'S'
set -g @resurrect-restore 'R'
```

Save and restore are rare and consequential; the menus are daily. Shift also
makes an accidental restore less likely than `C-r` did.

## Part F — Testing

bats, in `scripts/scripts/tests/`, against the existing argv-recording stubs.

**Framework (`tests/fzf_menu.bats`, `tests/picker.bats`):**
- `@menu` is recognised by `action_sigil` and stripped by `action_body`
- `explain_action` names the target menu for an `@menu` row
- `popup()` sizes to the tallest `@menu` target, not to the parent's own rows
- `popup()` still clamps at `POPUP_MAX_ITEMS`
- `--empty-message` prints and returns `PICKER_NO_SELECTION` without invoking
  fzf, verified by the stub recording no argv
- absent `--empty-message`, empty input behaves exactly as before

**Domain pickers (`tests/wt_pick.bats`, `tests/pr_pick.bats`, `tests/sc_pick.bats`):**
- each verb dispatches to the right command with the selected identifier,
  verified with stubbed `git` / `gh` / `short` / `ts` / worktree scripts
- an unknown verb exits 2 with a usage message
- an empty list produces the empty message and exits 0
- escape (stub abort) exits 0 and runs no action
- `wt-pick` excludes the main repository and the current worktree

**Confirmation gate (`tests/worktree_confirm.bats`):**
- cancel runs neither `switch-client` nor `git-worktree-cleanup`
- confirm runs both, in that order
- dirty and unpushed counts appear in the prompt text
- a worktree with no upstream reports no unpushed count rather than erroring
- with no tty the gate wraps itself in `display-popup`; with a tty it renders
  inline and opens no popup

**Manual verification** (not automated — these need a live tmux client):
- each new binding opens its menu at the right size
- `menu.menu` chains into each leaf menu without the leaf scrolling
- `prefix Enter` still behaves normally after the `m` binding is added
- resurrect save/restore work on `S`/`R`
- the confirmation gate renders correctly in its popup

## Risks

- ~~**`short` search operators**~~ Resolved: verified live on 2026-09-06,
  command recorded in B3.
- **`popup()` sizing** is the one place a change here can silently degrade
  the existing `git.menu`. The `POPUP_CHROME_ROWS` constant is not to be
  touched, and `tests/manual/verify-menu-fit` re-measures if it seems wrong.
- **`t` and `s` displacing tmux defaults** is a habit change, not a technical
  risk, and is reversible by deleting two lines.
