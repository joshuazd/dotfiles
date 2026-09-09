# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Testing

Run tests locally to validate config changes:

```bash
# Vim config loads without errors
vim -N -u vim/.vimrc -c 'quit'

# Shell configs load
bash -c 'source shell/.bash_profile'
zsh -c 'source shell/.zshrc'

# Tmux config syntax
tmux -f tmux/.tmux.conf list-keys >/dev/null
```

CI (GitHub Actions) tests all three on Ubuntu and macOS on push/PR to main/master.

## Installation

Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink config packages into `$HOME`:

```bash
stow vim shell tmux git config   # install all
stow -D vim                      # remove vim symlinks
```

`shell/.bin/install-symlinks` holds the authoritative package list; the line
above is illustrative and does not name every package.

After installing vim, run `:PackUpdate` to install remote plugins.

## Architecture

### Shell

- `.shrc` and `.profile` are shared between bash and zsh — shell-agnostic config lives here
- `.bashrc` / `.zshrc` source `.shrc` and add shell-specific settings
- `.functions` and `.aliases` are sourced by `.bashrc` and `.zshrc` individually
- Optional files (`.fzf.bash`, `.fzf.zsh`, `.secrets`, `~/.ripgrep`, `~/.zshenv.local`) are sourced only if they exist
- `.zshenv` is for non-interactive, non-login zsh only (`zsh -c ...`, which is what `tmux respawn-pane` runs): it returns immediately for login and interactive shells, which keep getting their environment from `.zprofile` and `.zshrc`. It assembles PATH from `.profile` (guarded, since `.profile` prepends), applies brew shellenv, and puts mise's *shims* on PATH rather than running `mise activate`, whose precmd hook never fires without a prompt

### Vim

- `.vimrc` is the entry point
- Native package management via `pack/`:
  - `pack/local/start/` — custom local plugins (always loaded)
  - `pack/remote/start/` — external plugins managed by minpac
- `autoload/` — lazy-loaded helper functions (grep, git blame, ruby test runner, XML tools, etc.)
- LSP (vim-lsc) and linting (ALE) are intentionally used together — not redundant

### Tmux

- Main config: `.tmux.conf`
- Custom scripts and theme in `.tmux_custom/` (referenced via `$TMUX_CUSTOM` env var)
- Prefix: `C-Space`; base-index: 1; mouse: on; escape-time: 0

### iTerm2

- `iterm2/` — one Dynamic Profile, `Vigil Panel`, symlinked into
  `~/Library/Application Support/iTerm2/DynamicProfiles/`

#### The `Vigil Panel` profile exists so a restored pane relaunches vigil

The point of the profile is the `Command` field. iTerm2's window arrangements
are what make a layout survive a restart, and an arrangement restores a pane's
*profile*, not a command someone typed at a prompt - so a pane where `vigil
--panel` was typed by hand comes back as a bare shell. A pane opened with this
profile comes back running vigil. **JSON cannot hold the comment saying so**,
which is why this is here (same reason as the `TERM_PROGRAM` note below).

The command is `/bin/zsh -c 'vigil --panel; exec /bin/zsh -l'`, and both halves
are load-bearing:

- **`zsh -c` rather than running vigil directly.** A profile's custom command is
  not a login shell: it gets `PATH=/usr/bin:/bin:/usr/sbin:/sbin` plus iTerm2's
  own utilities - no Homebrew, no `~/.local/bin`. `gh` is then missing, vigil's
  `startupDependencies` check refuses to start, iTerm2 closes the pane, and the
  panel silently never appears. zsh reads `~/.zshenv` on *every* invocation,
  interactive or not, and that is where PATH is set, so `-c` alone recovers it
  without needing a login shell's rc files.
- **`exec /bin/zsh -l` afterwards**, the same idiom as `launch_claude_in_pane`:
  a pane whose command exits leaves a usable shell instead of vanishing. That is
  what makes the *next* startup failure visible rather than silent, and it is
  what `q` in the panel does.

`Dynamic Profile Parent Name` inherits font and colours from `Default`, so the
pane does not look foreign.

**AppleScript cannot build this layout, which is why there is no script for it.**
`split horizontally` always adds the new pane *below* the one it splits (verified
by eye - the sdef exposes no positional parameter, and there is no move or swap
verb), so a scripted split of a tmux pane can only put vigil underneath it.
Only iTerm2's Python API can place a pane above, via
`async_split_pane(vertical=False, before=True)`, and that costs enabling the API
server plus a Python runtime. Since an arrangement is what persists the layout
anyway, the split is done once by hand and saved - the profile is the only part
that needs to be version-controlled.

**`Cmd+Shift+D` is the wrong way to make the pane, and setting the profile
afterwards does not fix it.** That binding is "Split Horizontally with *Current*
Profile", so the pane opens under `Default`; and applying `Vigil Panel` to an
already-running pane only changes appearance, because the shell in it has
already started. The result is a correctly-profiled pane running `-zsh` and no
vigil. The pane has to be *created* with the profile:

```bash
osascript -e 'tell application "iTerm2" to tell current session of current tab of current window to split horizontally with profile "Vigil Panel"'
```

Setup, once: run that from the tmux pane, drag the new pane above it (iTerm2
does allow dragging panes), then `Window > Save Window Arrangement` and
`Settings > General > Startup > Open default window arrangement`. Creating the
pane from the profile rather than typing `vigil --panel` into it is also what
makes the arrangement restore it correctly.

Set vigil's own `panel_auto = "false"` in the `[settings]` table of
`~/.config/vigil/config.toml` too, or every tmux session also gets its own
redundant panel.

The arrangement does not have to be named `Default`: iTerm2 records which one is
default under the separate `Default Arrangement Name` key, so the timestamped
name `Window > Save Window Arrangement` suggests is fine.

**Only the vigil half of the window self-restores.** An arrangement stores each
pane's actual command, and the tmux pane is a plain login shell (`Custom
Command: No`, `Command: ""`), so after an iTerm2 restart the bottom pane comes
back as a bare zsh - nothing in `shell/.zshrc` auto-attaches tmux. The vigil
pane comes back running vigil, because its profile supplies the command. Fixing
the other half means a second Dynamic Profile along the lines of
`/bin/zsh -c 'tmux new-session -A -s main; exec /bin/zsh -l'` and recreating the
bottom pane with it; until then, `tmux a` after a restart is the whole of it.

Two aids to debugging this layout: `sessions of <tab>` comes back in **layout
order, top to bottom**, not creation order - which is how you check from a
script whether the panel actually ended up above the tmux pane. And the
`Window Arrangements` key in `~/Library/Preferences/com.googlecode.iterm2.plist`
holds the recorded per-pane `Command`, which is what settles whether a restart
will really bring a pane back running something.

### Config

- `config/` holds miscellaneous tool configs (`.dir_colors`, etc.)
- `colors/` holds legacy terminal color themes (mintty/Xresources for Windows/Linux — not used on macOS). Active color themes live in `vim/.vim/colors/` and `tmux/.tmux_custom/colors/`

### Scripts

- `scripts/` — utility scripts installed via stow (dispatch, gh helpers, tmux utilities, etc.)

### Menus

Action menus, opened over the focused pane.

- `scripts/scripts/lib/picker.sh` — the only place fzf argv is built (`pick_one` / `pick_many`)
- `scripts/scripts/fzf-menu` — runs a declarative `menus/<name>.menu` file
- `scripts/scripts/menus/*.menu` — one file per menu, `Label<TAB>command`, tab separated. A leading sigil says where the command runs: none (in the popup), `@window`, `@pane`, `@bg`, `@menu`, `@quiet`. A `&` in the label marks its mnemonic key (`&Fetch` binds `f`), folded to lowercase
- `scripts/scripts/{wt,pr,sc}-pick` — list-then-act pickers for the entries that need a second choice. Dynamic lists are scripts, not menu syntax

Bindings: `prefix g` git, `w` worktree, `r` pr, `t` tmux, `s` shortcut, `m` all menus. Each has a `C-` variant except `m` (terminals send `C-m` as Enter).

**Two backends, chosen by measurement:**

- native `tmux display-menu` whenever the items fit the client
- the fzf picker when they do not, because a menu too tall for the terminal is not displayed at all - no scroll, no truncation, no error

`display-menu` runs a command rather than returning a selection, so every picker has a list half and an `--act <verb> <value>` half. Both backends drive the same `--act`, which is what makes the fallback safe to rely on.

**It also cannot be relied on to block until its menu is answered** - measured returning 0 a second after opening, with the menu untouched. So confirmations hand the gate an action (`wt-confirm --run <command>`) and the chosen item runs it, the way tmux writes its own (`Yes y { kill-pane }`). Nothing reads an answer back. See `scripts/scripts/CLAUDE.md`.

Previews and type-to-filter exist only on the fzf path. `lib/menu.sh` owns `display-menu` argv the way `lib/picker.sh` owns fzf's.

To add a menu: drop a `.menu` file in `menus/` and bind `fzf-menu --popup <name>`. No script needed unless an entry has to pick from a list.

### Claude

- `claude/` — Claude Code trust settings (`CLAUDE.md`)

#### `TERM_PROGRAM: Apple_Terminal` in settings.json is deliberate

`claude/.claude/settings.json` sets `TERM_PROGRAM=Apple_Terminal` even though
the terminal is not Apple Terminal. **Do not "correct" this.** It is what stops
tmux popups flickering, and JSON cannot hold the comment saying so.

Claude Code decides whether to use synchronized output (DECSET 2026) like this:

```
aO():   if (TMUX) return synchronizedOutputSupported === true
probe:  skip DECRQM(2026) if no XTVERSION reply OR TERM_PROGRAM === "Apple_Terminal"
        skipped -> undefined status -> synchronizedOutputSupported = false
```

tmux repaints an overlay's outermost cells whenever a pane flushes a
synchronized-output frame, so any `display-popup` drawn over a working Claude
tore continuously along its border. Claiming to be Apple Terminal makes Claude
skip the probe, emit no 2026 frames, and the tearing stops.

Two things worth knowing before changing it:

- **`TERM_PROGRAM === "tmux"`, its real value here, is compared nowhere in the
  Claude Code bundle**, so nothing is lost by replacing it. The only behaviour
  it does change is strikethrough support, which is why
  `CLAUDE_CODE_FORCE_STRIKETHROUGH=1` sits beside it.
- **Unsetting `TMUX` also disables sync output** (the allowlist below the TMUX
  branch matches neither `tmux` nor `xterm-256color`) but breaks the tmux
  clipboard, pane targeting and agent-teams panes. It was tried and rejected.

`CLAUDE_CODE_FORCE_SYNC_OUTPUT` cannot help either way: the `TMUX` branch
returns before it is read.

Verify with `claude --debug-file /tmp/cc.log` and grep for `DECRQM`.
