# Dotfiles

[![Vim Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-vim.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-vim.yml)
[![Shell Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-shell.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-shell.yml)
[![Tmux Config Tests](https://github.com/joshuazd/dotfiles/actions/workflows/test-tmux.yml/badge.svg)](https://github.com/joshuazd/dotfiles/actions/workflows/test-tmux.yml)

Personal configuration files for Unix-based development environments.

## Overview

This repository contains configuration files organized by tool:

- **vim/** - Comprehensive Vim configuration with LSP support, native package management, and custom plugins
- **shell/** - Shell configurations for bash and zsh with shared functions and aliases
- **tmux/** - Terminal multiplexer configuration with custom keybindings
- **git/** - Git configuration
- **config/** - Additional tool configurations

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

### Prerequisites

```bash
# macOS
brew install vim git tmux stow

# Ubuntu/Debian
sudo apt-get install vim git tmux stow
```

### Using GNU Stow

This repository is organized for use with [GNU Stow](https://www.gnu.org/software/stow/), which creates symlinks automatically.

1. Clone the repository:
```bash
git clone https://github.com/joshuazd/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Use stow to install configurations:

```bash
# Install all configurations
stow vim shell tmux git config

# Or install individual configurations
stow vim     # Installs vim configuration
stow shell   # Installs shell configuration
stow tmux    # Installs tmux configuration
stow git     # Installs git configuration
stow config  # Installs tool configuration
```

3. To uninstall a configuration:
```bash
stow -D vim  # Removes vim symlinks
```

**Note:** Stow creates symlinks from `~/.dotfiles/<package>/<file>` to `~/<file>`. For example, `~/.dotfiles/vim/.vimrc` becomes `~/.vimrc`.

### Post-Installation

**Vim plugins:**
```bash
vim -c 'PackUpdate' -c 'qa'
```

**Language servers (optional):**
```bash
# Ruby
gem install solargraph

# Python
pip install python-lsp-server flake8

# JavaScript/TypeScript
npm install -g typescript-language-server
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
│   └── .aliases         # Shared aliases
├── tmux/                # Tmux configuration
├── git/                 # Git configuration
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

