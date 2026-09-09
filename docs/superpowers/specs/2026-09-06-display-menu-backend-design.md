# Display-Menu Backend Design

**Date:** 2026-09-06
**Status:** Proposed
**Builds on:** `docs/superpowers/specs/2026-09-06-menu-expansion-design.md`

## Goal

Render every menu through native `tmux display-menu`, falling back to the fzf
picker only when a list is too tall for a menu to display at all.

## Why now

The menus were built on fzf partly because `display-menu` was tried early and
rejected: its borders and title flickered. That flicker turned out not to be a
`display-menu` problem at all - tmux repaints an overlay's outer ring whenever
a pane flushes a DECSET 2026 frame, and Claude Code was emitting them. With
`TERM_PROGRAM=Apple_Terminal` in `claude/.claude/settings.json` the frames stop
and so does the tearing, which removes the original objection.

What a native menu buys: no fzf process per open, no popup geometry arithmetic
(`POPUP_CHROME_ROWS` stops mattering for the menu path), single-key selection
without the `pos(N)` binding workaround, and tmux's own styling.

## The constraint that shapes everything

From `man tmux`:

> If the menu is too large to fit on the terminal, **it is not displayed.**

No scrolling, no truncation, no error - a silent blank. So the backend choice
cannot be a preference; it has to be a measurement, and the fzf path has to
remain for lists that outgrow the client.

## The other structural difference

**`display-menu` does not return a selection.** fzf hands the chosen row back
on stdout; `display-menu` instead runs the item's tmux command. Every caller
therefore splits in two:

- a **list** half that produces `value<TAB>label` rows
- an **act** half that takes one value and does the work

Both backends drive the same act half, which is what makes the fallback
honest: the two paths differ only in how a value is chosen.

## Non-Goals

- Previews in menu mode. `display-menu` has no preview pane; the `--explain`
  preview survives only on the fzf fallback path. Accepted.
- Type-to-filter in menu mode. Same reason.
- Removing the fzf path. It is the fallback and stays fully supported.
- Changing the `.menu` file format.

## Global Constraints

- bash 3.2 compatible; `${1+"${@}"}` for possibly-empty argv under `nounset`.
- `set -o errexit -o nounset -o pipefail` in every script.
- Package header block and `help_wanted` handling on every script.
- Google Shell Style function comment blocks.
- `shellcheck` clean via `make lint`.
- New scripts added to `SHELL_SCRIPTS` in `scripts/scripts/Makefile`.
- `lib/picker.sh` remains the only place fzf argv is constructed.
  `lib/menu.sh` becomes the only place `display-menu` argv is constructed.
- Values crossing into a `run-shell` command are escaped with `printf '%q'`.
- No em dashes.

## Part A - `lib/menu.sh`

The only place `display-menu` argv is built.

### A1. `menu_client_height`

```sh
tmux display-message -p '#{client_height}'
```

Empty or non-numeric output means "cannot measure", which counts as "does not
fit" - the fzf path is always safe, a blank menu never is.

### A2. `menu_fits <item-count>`

Returns 0 when a menu of that many items can be displayed.

```
item-count + MENU_CHROME_ROWS <= client_height
```

`MENU_CHROME_ROWS` covers the border (2) and the title row (1), plus one row
of slack so a menu never lands exactly on the limit. **Measured, not derived**
- `tests/manual/verify-menu-fit` gets a `--menu` mode that counts what a real
client actually displays, for the same reason `POPUP_CHROME_ROWS` is measured:
an estimate one row short here does not scroll, it blanks.

### A3. `menu_show <title> <act-prefix> < rows`

Reads `value<TAB>label` rows on stdin and displays them.

- Item name is the **label alone**. It is not numbered: tmux renders the key
  at the end of the line itself, and numbering the label duplicates it.
- Item key is the digit `1`-`9` for the first nine items, empty after that.
  Empty keys are navigable with the arrow keys.
- Item command is `run-shell -b "<act-prefix> <printf %q value>"`.
- A row whose label is `-` becomes a `display-menu` separator (an empty name).

Styling, in one place so all menus match:

```sh
tmux display-menu -T "#[align=centre] ${title} " -b rounded \
  -x C -y C -- "${args[@]}"
```

`-T` is used for the title rather than a disabled first item. An item-as-title
was the earlier attempt and it was selectable and dimmed; a real title is
neither.

**Position: centred on the focused pane, not the terminal.** `-x C -y C`
centres on the whole client, which on a split window puts the menu away from
where the user is looking. `-x`/`-y` also take a format, and tmux expands
`popup_pane_left/right/top/bottom` and `popup_width/height` while positioning
a menu, so the centre can be computed with `#{e|op:a,b}` arithmetic. This is a
nice-to-have: the `popup_pane_*` variables are empty outside a positioning
context and so can only be confirmed on a live client, and the fallback if
they do not expand is plain `-x C -y C`.

`--` terminates options, because a label may legitimately begin with `-`
(which is also how `display-menu` marks a disabled item, so the two uses must
not collide by accident).

### A4. `menu_or_pick <title> <act-prefix> [pick_one options...] < rows`

The decision point every caller uses:

1. buffer the rows and count them
2. `menu_fits` → `menu_show`
3. otherwise → `pick_one` with the caller's options, then invoke
   `<act-prefix> <selected value>`

Returns `PICKER_EMPTY` on no rows, `PICKER_QUIET_EXIT` when the user escapes
the fzf path. `display-menu` gives no signal for a dismissed menu, so the menu
path returns 0 and there is nothing to pause on anyway.

## Part B - `fzf-menu` gains a `--run` mode

`--popup <name>` becomes backend-aware:

- rows fit → `menu_show` with act-prefix `fzf-menu --run`
- otherwise → today's `display-popup` + inline fzf path, unchanged

`--run <command>` is the act half: exactly today's `run_action`, with one
change. The bare (no sigil) case currently runs inside the fzf popup and
pauses so output can be read. In menu mode there is no popup, so a bare
command opens its own:

```sh
tmux display-popup -E -w 80% -h 60% "<command>; printf '\n'; read -r -n 1 -p 'Press any key to close... ' _"
```

Bordered, matching the other output popups. `@window`, `@pane`, `@bg` and
`@menu` are unchanged - none of them needed the popup.

`@menu` in menu mode re-enters `fzf-menu --popup <target>`, so a chained menu
gets its own backend decision rather than inheriting the parent's.

## Part C - The pickers split list from act

`wt-pick`, `pr-pick` and `sc-pick` each gain `--act <verb> <value>` and route
their existing verbs through `menu_or_pick`.

```
wt-pick switch              # list, choose, act
wt-pick --act switch <path> # act on a known value
```

The act half is what a menu item invokes and what the fzf path calls after
`pick_one` returns. Verb validation happens in both entry points, so an
`--act` with a bad verb is a usage error rather than a silent no-op.

`wt-pick --act remove <path>` keeps going through `wt-confirm`, which is
unchanged: called from a `run-shell` it has no tty and opens its own popup,
which is exactly the branch it already has.

Titles: `Worktree to switch`, `PR to review`, `Story to implement` - the same
text the fzf prompt uses today, so the two backends read alike.

## Part D - Testing

The tmux stub already records argv, which is all the menu path needs.

**`tests/menu_lib.bats`:**
- `menu_fits` is true when items plus chrome fit the client height
- `menu_fits` is false when they do not, and false when the height cannot be
  measured
- `menu_show` passes the label as the item name, unnumbered
- `menu_show` assigns digit keys to the first nine items and empty keys after
- `menu_show` builds `run-shell` commands containing the escaped value
- a value containing a space or a quote survives into the command intact
- a `-` label becomes a separator, and a label starting with `-` is not eaten
  as an option
- `menu_show` sets a title with `-T`, not a disabled first item

**`tests/fzf_menu.bats` additions:**
- `--popup` uses `display-menu` when the rows fit
- `--popup` falls back to `display-popup` plus fzf when they do not
- `--run` on a bare command opens a bordered `display-popup`
- `--run` honours `@window`, `@pane`, `@bg`, `@menu` exactly as before

**Per-picker additions** (`wt_pick`, `pr_pick`, `sc_pick`):
- the verb path renders a menu whose items call `--act <verb>`
- `--act <verb> <value>` performs the action without a picker
- `--act` with an unknown verb exits 2
- the fzf fallback still reaches the same `--act` path

**Manual verification** (needs a live client):
- each menu opens as a native menu, correctly styled, title not selectable
- digit keys choose; arrows navigate; Escape dismisses
- a repo with more open PRs than the client is tall falls back to fzf rather
  than blanking
- `git status` from `git.menu` opens a bordered popup and waits for a key
- `prefix m` into a leaf menu re-decides the backend

## Risks

- **`MENU_CHROME_ROWS` guessed rather than measured** would blank a full menu
  instead of shrinking it. This is the one number to measure on a real client
  before trusting.
- **Losing the previews** is a real regression in menu mode, accepted
  deliberately. If the explanations turn out to be load-bearing, folding a
  short form into the label is the fallback, and it works on both backends.
- **`display-menu` styling** was the other early objection (uncolored
  separator rows, dim title). `-T` and `-b` address the reported cases; the
  rest is a look to iterate on once it is on screen.
