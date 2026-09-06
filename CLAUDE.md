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

### Config

- `config/` holds miscellaneous tool configs (`.dir_colors`, etc.)
- `colors/` holds legacy terminal color themes (mintty/Xresources for Windows/Linux — not used on macOS). Active color themes live in `vim/.vim/colors/` and `tmux/.tmux_custom/colors/`

### Scripts

- `scripts/` — utility scripts installed via stow (dispatch, gh helpers, tmux utilities, etc.)

### Menus

Action menus, opened over the focused pane.

- `scripts/scripts/lib/picker.sh` — the only place fzf argv is built (`pick_one` / `pick_many`)
- `scripts/scripts/fzf-menu` — runs a declarative `menus/<name>.menu` file
- `scripts/scripts/menus/*.menu` — one file per menu, `Label<TAB>command`, tab separated. A leading sigil says where the command runs: none (in the popup), `@window`, `@pane`, `@bg`, `@menu`
- `scripts/scripts/{wt,pr,sc}-pick` — list-then-act pickers for the entries that need a second choice. Dynamic lists are scripts, not menu syntax

Bindings: `prefix g` git, `w` worktree, `r` pr, `t` tmux, `s` shortcut, `m` all menus. Each has a `C-` variant except `m` (terminals send `C-m` as Enter).

**Two backends, chosen by measurement:**

- native `tmux display-menu` whenever the items fit the client
- the fzf picker when they do not, because a menu too tall for the terminal is not displayed at all - no scroll, no truncation, no error

`display-menu` runs a command rather than returning a selection, so every picker has a list half and an `--act <verb> <value>` half. Both backends drive the same `--act`, which is what makes the fallback safe to rely on.

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
