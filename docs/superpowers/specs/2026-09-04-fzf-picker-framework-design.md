# fzf picker framework

Date: 2026-09-04
Status: approved, not yet implemented

## Problem

Every fzf-driven popup in `scripts/` repeats the same preamble: re-export
`PATH` (a `display-popup` runs with no profile), set `--ansi`, pick a
delimiter and `--with-nth`, choose a geometry, then interpret the selection.
`run_worktree_popup` carries a hand-rolled version of it today, and any new
picker would carry another copy.

Separately there is no way to add a small menu of actions without writing a
whole script, which is why menus that would be useful (git actions, make
targets, worktree operations) do not exist.

## Non-goals

- Replacing `vigil`. Vigil owns the session dashboard; this owns one-shot
  pickers.
- A menu registry that scans the filesystem for capabilities. Menus are
  listed explicitly.
- Reimplementing `tmux display-menu`. That stays the right tool for a
  three-item confirmation; this is for lists long enough to want typing.

## Architecture

Three tiers over one primitive.

```
tier 3   cleanup-sessions, branch picker, ...   (bespoke scripts)
tier 2   fzf-menu <name>  +  menus/<name>.menu  (menus as data)
tier 1   lib/picker.sh    pick_one / pick_many  (the primitive)
```

Tier 2 is implemented in terms of tier 1. Tier 3 skips tier 2 and calls
tier 1 directly. Nothing calls `fzf` directly.

## Tier 1: `lib/picker.sh`

Follows the conventions of the existing libs: source guard
(`__LIB_PICKER_LOADED`), `#####` doc comment per function, sourced by
`common.sh`.

### Interface

```bash
pick_one  [options] < rows    # → one selected row on stdout
pick_many [options] < rows    # → selected rows on stdout, newline separated
```

Rows are TAB-delimited. The display column is last by convention, so
`--with-nth` is uniform and callers can carry hidden leading fields (an id, a
path, a session name) the way `cleanup-sessions` carries
`name<TAB>path<TAB>display`.

| Option | Default | Meaning |
| --- | --- | --- |
| `--prompt P` | `"> "` | fzf prompt |
| `--header H` | none | header line |
| `--with-nth N` | `-1` (last field) | displayed column(s) |
| `--preview CMD` | none | preview command |
| `--size GEO` | `center,80%,70%` | passed to `--tmux` |
| `--delimiter D` | TAB | field delimiter |

### Behavior

- Exports `PATH` for the popup context before invoking fzf, via the fixed
  `PICKER_PATH_DIRS` list. This is the boilerplate the lib exists to own.
- Always passes `--ansi --cycle --layout=reverse`, so colored rows from
  `vigil rows` and similar render correctly.
- `pick_many` adds `--multi` and binds `ctrl-a:select-all`,
  `ctrl-d:deselect-all`.
- Deliberately opts into a centered modal via `--size`, overriding the
  unobtrusive `--tmux bottom,50%` default that `.fzfrc` sets for everyday
  `C-t` / `C-r` / `M-c`. Two contexts, two treatments.
- `--tmux`/`--size` is IGNORED when fzf is already running inside a `tmux
  display-popup`. Per `man tmux`, a display-popup started inside an existing
  popup accepts only `-b -B -C -E -EE -K -N -s -S`; every other option,
  including `-w`/`-h`, is silently dropped for the *inner* popup, but here it
  is fzf's own `--tmux` invocation being ignored by the outer popup for the
  same reason. `fzf-menu`'s shipping path is the `prefix g` binding, which is
  itself a popup, so `PICKER_DEFAULT_SIZE` and `--size` are inert there and
  the binding's `-w`/`-h` govern instead. `--size` still matters for a tier-3
  picker invoked from a normal pane.

### Error handling

- Nothing selected, or the user pressed Escape: exit 1, print nothing.
  Callers use `|| exit 0`. This is the common path, not an error.
- `fzf` not on `PATH`: exit 2 with `error "fzf not found"`.
- Empty stdin: exit 1 with `warn "nothing to pick from"`. fzf is not
  launched, so the user does not get an empty modal.
- Exit codes are named constants (`PICKER_NO_SELECTION=1`,
  `PICKER_UNAVAILABLE=2`) exported by the lib, matching how `lib/tmux.sh`
  exports `SESSION_EXISTED`.

## Tier 2: `fzf-menu`

One generic script. `fzf-menu <name>` loads `scripts/menus/<name>.menu`,
renders it with `pick_one`, and dispatches the chosen command.

### Menu file format

One file per menu. Line 1 is a `#` comment used as the fzf header. Each
subsequent non-blank, non-comment line is `label<TAB>command`.

```
# Git actions
Fetch and prune	git fetch --all --prune
Rebase on main	git rebase origin/main
Interactive rebase	@window git rebase -i origin/main
Checkout branch	fbr
Blame this file	@bg tig blame
```

### Sigils

A leading sigil on the command answers "where does this run", which is the
one thing a flat label→command table cannot express and the usual reason a
menu would otherwise need to become a script.

| Sigil | Behavior |
| --- | --- |
| *(none)* | Run in the current popup; pause for a keypress before closing. |
| `@window` | New tmux window in `#{pane_current_path}`. |
| `@pane` | `send-keys` into the current pane. |
| `@bg` | Detached via `nohup`; output appended to `~/.cache/fzf-menu.log`. |

Commands run through `sh -c` in the directory the menu was invoked from.
Unknown sigil: `error` and exit 2, rather than running the line verbatim.

### Binding a menu

```tmux
bind g display-popup -E 'fzf-menu git'
```

### Error handling

- Missing menu file: `error "no such menu: <name>"`, exit 2, and list the
  available menu names.
- Malformed line (no TAB): `warn` naming the file and line number, skip the
  line, keep the rest of the menu usable.
- Menu file with no valid rows: treated as empty stdin by tier 1.
- The dispatched command's own exit status is reported but does not become
  `fzf-menu`'s status; a failed action should not look like a failed menu.
  For the default (in-popup) sigil the status is printed before the pause, so
  a failure is visible rather than flashing past.

## Tier 3: bespoke pickers

Scripts that need logic a table cannot hold. They source `lib/picker.sh` and
call `pick_many` directly. No menu file, no `fzf-menu` involvement.

First candidates, in order:

1. **`cleanup-sessions`** — new. fzf multi-select over tmux sessions
   annotated with vigil's PR state, then parallel teardown through
   `git-worktree-cleanup`. The capability vigil lacks today.
2. **`run_worktree_popup`** — existing; drop its bespoke popup handling onto
   tier 1.

Neither is in scope for the first implementation. They are the reason the
primitive is shaped the way it is.

## Related config changes

Two one-line changes, independent of the framework but part of the same
motivation.

**`shell/.fzfrc`** — replace `--tmux 90%,70%` with `--tmux bottom,50%`, so
everyday `C-t` / `C-r` / `M-c` stop covering the content being referenced.
Tier 1 opts back into a centered modal via its `--size` default.

**`tmux/.tmux_custom/colors/nord.tmux`** — in both `window-status-format` and
`window-status-current-format`, replace `#W` with:

```
#{?#{||:#{m:SC-*,#{session_name}},#{m:PR-*,#{session_name}}},#W,#{?#{m:✳ *,#{pane_title}},✳ #{=24:#{s/^✳ //:pane_title}},#W}}
```

Claude Code renames its window to `claude` (which sets `automatic-rename=0`)
and its `pane_current_command` is the versioned binary (`2.1.260`), so neither
the window name nor the command distinguishes several Claude windows in one
session. `pane_title` already carries a per-window task summary that is
currently not displayed.

Dispatched sessions are excluded on purpose: their windows must keep reading
`claude` and `server`. There is no window-level attribute that separates a
dispatched Claude window from an ad-hoc one — both end up `name=claude`,
`automatic-rename=0` — so the discriminator is the session name. Every
dispatched session is named by `session_name_from_title`, which always
prefixes `SC-` or `PR-`. **If that prefix convention changes, this expression
must change with it.**

Windows with no Claude running have no `✳ ` prefix and fall through to `#W`
unchanged in either kind of session.

## Testing

bats, under `scripts/tests/`, matching the existing suite.

- **`picker_lib.bats`** — stub `fzf` with a script that records its argv and
  echoes a fixed row. Assert: `--with-nth` and delimiter defaults, `--multi`
  present for `pick_many` and absent for `pick_one`, `--size` reaching
  `--tmux`, exit 1 on empty stdin without launching fzf, exit 2 when fzf is
  absent.
- **`fzf_menu.bats`** — fixture menu files. Assert: header taken from line 1,
  each sigil dispatching to the right mechanism (tmux calls verified with the
  argv-recording tmux stub `tmux_lib.bats` already uses), malformed line
  skipped with a warning, missing menu file exits 2 and lists alternatives.

`make lint` (shellcheck) covers both new scripts.

## File layout

```
scripts/scripts/
  lib/picker.sh          new
  fzf-menu               new
  menus/git.menu         new (first menu, proves the format)
  tests/stubs/fzf        new (argv-recording stub, mirrors tests/stubs/tmux)
  tests/picker_lib.bats  new
  tests/fzf_menu.bats    new
  tests/helper.bash      modified — setup_fzf_stub, fzf_args, assert/refute_fzf_called
  common.sh              modified — source picker.sh
  Makefile               modified — add fzf-menu to SHELL_SCRIPTS
tmux/.tmux.conf          modified — bind prefix g / C-g to the git menu
shell/.fzfrc             modified — bottom,50%
tmux/.tmux_custom/colors/nord.tmux   modified — pane_title in window format
```

Note `common.sh` sits beside the scripts, not inside `lib/`; the Makefile
lists it separately from the `lib/*.sh` wildcard for that reason.
