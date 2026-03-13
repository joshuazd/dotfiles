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
- Optional files (`.fzf.bash`, `.fzf.zsh`, `.secrets`, `~/.ripgrep`) are sourced only if they exist

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

### Claude

- `claude/` — Claude Code trust settings (`CLAUDE.md`)
