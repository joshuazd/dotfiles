# Dotfiles

Personal configuration files for Unix-based development environments.

[![Vim Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-vim.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-vim.yml)
[![Shell Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-shell.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-shell.yml)
[![Tmux Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-tmux.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-tmux.yml)

## Quick Install

Requires `git` (curl is needed to run this command and assumed present).

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh)"
```

To clone to a custom path (default is `~/dotfiles`):

```bash
DOTFILES=~/.dotfiles bash -c "$(curl -fsSL https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh)"
```

## Overview

This repository contains configuration files organized by tool:

- **vim/** - Comprehensive Vim configuration with LSP support, native package management, and custom plugins
- **shell/** - Shell configurations for bash and zsh with shared functions and aliases
- **tmux/** - Terminal multiplexer configuration with custom keybindings
- **git/** - Git configuration
- **config/** - Additional tool configurations
- **scripts/** - Utility scripts (dispatch, gh helpers, tmux utilities)
- **claude/** - Claude Code trust settings

## Features

### Vim Configuration
- Native package management with minpac
- LSP support via vim-lsc (Ruby, Python, JavaScript/TypeScript, Java)
- Linting and fixing with ALE
- Manual completion with mucomplete
- Custom text objects and navigation enhancements
- Extensive language support (Ruby/Rails, Python, JavaScript, Go, etc.)

See [vim/README.md](vim/README.md) for detailed documentation.

### Shell Configuration
- Shared configuration between bash and zsh via .shrc and .profile
- Custom prompt with git branch information
- Ruby and Python version indicators in prompt
- FZF integration for fuzzy finding
- Comprehensive aliases and utility functions
- Vi mode with enhanced keybindings

## Installation

### Automated Install

The `jzd install` command handles tool installation and symlink setup. Packages are defined in `shell/.bin/packages.tsv` and installed via the native package manager (Homebrew on macOS, apt/dnf/pacman/apk on Linux).

```bash
git clone https://github.com/joshuazd/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install core tools + symlinks
shell/.bin/jzd install all

# Install everything (core + full, e.g. gh, nodejs, claude-code)
shell/.bin/jzd install all full
```

Individual steps:
```bash
jzd install tools           # core packages only
jzd install tools full      # core + full packages
jzd install symlinks        # stow dotfile symlinks
```

### Manual Install with Stow

This repository is organized for use with [GNU Stow](https://www.gnu.org/software/stow/), which creates symlinks automatically.

```bash
# Install all configurations
stow vim shell tmux git config scripts claude

# Or install individually
stow vim     # Vim configuration
stow shell   # Shell configuration + install scripts

# Remove a configuration
stow -D vim  # Removes vim symlinks
```

**Note:** Stow creates symlinks from `~/dotfiles/<package>/<file>` to `~/<file>`.

### Post-Installation

**Vim plugins:**
```bash
vim -c 'PackUpdate' -c 'qa'
```

**Language servers (optional):**
```bash
gem install solargraph                    # Ruby
pip install python-lsp-server flake8     # Python
npm install -g typescript-language-server # JavaScript/TypeScript
```

## Testing

GitHub Actions automatically test configurations on:
- Ubuntu and macOS
- Bash and Zsh (for shell configs)
- Triggered on push to main/master and pull requests

Run tests locally:
```bash
# Test vim config loads
vim -u vim/.vimrc -c 'quit'

# Test bash config loads
bash -c 'source shell/.bash_profile'

# Test zsh config loads
zsh -c 'source shell/.zshrc'
```

## Structure

```
dotfiles/
├── .github/workflows/    # GitHub Actions CI
├── vim/                  # Vim configuration
│   ├── .vimrc           # Main config file
│   └── .vim/            # Runtime files, plugins, autoload
├── shell/               # Shell configuration
│   ├── .bashrc          # Bash configuration
│   ├── .zshrc           # Zsh configuration
│   ├── .shrc            # Shared shell config
│   ├── .profile         # Login shell config
│   ├── .functions       # Shared functions
│   ├── .aliases         # Shared aliases
│   └── .bin/            # Utility scripts (30+)
├── tmux/                # Tmux configuration
├── git/                 # Git configuration
├── scripts/             # Stow-managed utility scripts
├── claude/              # Claude Code trust settings
└── config/              # Misc tool configs
```

## Maintenance

**Update vim plugins:**
```bash
vim -c 'PackUpdate' -c 'qa'
```

**Clean unused plugins:**
```bash
vim -c 'PackClean' -c 'qa'
```

**Reload shell configuration:**
```bash
source ~/.bashrc  # or ~/.zshrc
```

## License

MIT

