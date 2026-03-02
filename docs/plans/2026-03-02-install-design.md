# Install System Design

**Date:** 2026-03-02
**Status:** Approved

## Goal

A cross-platform machine setup that installs tools and stows dotfiles on Mac and Linux
(Ubuntu/Debian, Fedora/RHEL/Amazon Linux, Arch, Alpine). Fully automated, no prompts.
Tools install first (ensuring stow is present), then symlinks are created via stow.

## Architecture

The existing `jzd-install` dispatcher is preserved unchanged except for two small
arg-passthrough additions. New work lives in `shell/.bin/` (stowed to `~/.bin/`) and a
`Brewfile` at the dotfiles root.

```
jzd-install [subcommand] [tag]
  tools [core|full]  → install-tools [tag]
                           → detects OS
                           → install-tools-mac       (brew bundle)
                           → install-tools-apt [tag]
                           → install-tools-dnf [tag]
                           → install-tools-pacman [tag]
                           → install-tools-apk [tag]
  symlinks           → install-symlinks  (stow --restow for each package)
  pack               → install-pack      (unchanged — vim plugins via minpac)
  vim                → install-vim       (unchanged)
  all [core|full]    → install-all [tag] (tools → symlinks → pack → helptags)
```

## Package Manifest

Single source of truth: `shell/.bin/packages.tsv` (stowed to `~/.bin/packages.tsv`).

Format: `tool  tag  apt  dnf  pacman  apk`

- One row per tool; tab-separated
- `#` lines are comments
- `@name` in a package column means "call the `install_name` function" (special installer)
- Tags: `core` = always installed, `full` = opt-in extras

Platform scripts parse the TSV with `awk`, batch-install plain package names, then call
special installer functions for `@`-prefixed entries.

### Package List

| tool                | tag  | apt                 | dnf                   | pacman              | apk                 |
|---------------------|------|---------------------|-----------------------|---------------------|---------------------|
| zsh                 | core | zsh                 | zsh                   | zsh                 | zsh                 |
| vim                 | core | vim                 | vim                   | vim                 | vim                 |
| tmux                | core | tmux                | tmux                  | tmux                | tmux                |
| git                 | core | git                 | git                   | git                 | git                 |
| stow                | core | stow                | stow                  | stow                | stow                |
| fzf                 | core | fzf                 | fzf                   | fzf                 | fzf                 |
| ripgrep             | core | ripgrep             | ripgrep               | ripgrep             | ripgrep             |
| fd                  | core | fd-find             | fd-find               | fd                  | fd                  |
| bat                 | core | bat                 | bat                   | bat                 | bat                 |
| jq                  | core | jq                  | jq                    | jq                  | jq                  |
| curl                | core | curl                | curl                  | curl                | curl                |
| make                | core | make                | make                  | base-devel          | make                |
| universal-ctags     | core | universal-ctags     | ctags                 | ctags               | ctags               |
| the_silver_searcher | core | silversearcher-ag   | the_silver_searcher   | the_silver_searcher | the_silver_searcher |
| gh                  | full | @gh                 | @gh                   | @gh                 | @gh                 |
| mise                | full | @mise               | @mise                 | @mise               | @mise               |
| claude-code         | full | @claude-code        | @claude-code          | @claude-code        | @claude-code        |

### Special Installers

- `@gh` — GitHub CLI official repo (apt/dnf), AUR helper (pacman), binary release (apk)
- `@mise` — `curl https://mise.run | sh`
- `@claude-code` — `npm install -g @anthropic-ai/claude-code` (requires node via mise)

LSP servers (ruby-lsp, typescript-language-server, pylsp) are intentionally excluded —
they are installed manually per-project.

## Mac: Brewfile

Lives at dotfiles root. `brew bundle` is idempotent; no core/full split needed on Mac
since everything is fast to install. Covers the same tools as the Linux core+full set,
plus `node` (for claude-code).

## Stow: Updated install-symlinks

Replaces the old manual `ln -s` loop. Runs `stow --restow` for each package:
`vim shell tmux git config scripts claude`. Checks that stow is available first (fails
clearly if tools haven't been installed yet).

## install-all Ordering

1. `install-tools [tag]` — installs stow and all other tools
2. `install-symlinks` — stows all packages
3. `install-pack` — installs vim plugins
4. `vim +helptags\ ALL +qall` — generates helptags

Drops `install-tmux` and `install-vim` (they built ancient versions from source; package
managers now provide current versions).

## Files Changed

| File | Change |
|------|--------|
| `Brewfile` | New — declarative Mac package list |
| `shell/.bin/packages.tsv` | New — cross-platform package manifest |
| `shell/.bin/install-tools` | Updated — OS detector, delegates to platform scripts |
| `shell/.bin/install-tools-mac` | New — `brew bundle` wrapper |
| `shell/.bin/install-tools-apt` | New — Ubuntu/Debian with core/full tags |
| `shell/.bin/install-tools-dnf` | New — Fedora/RHEL/Amazon Linux with core/full tags |
| `shell/.bin/install-tools-pacman` | New — Arch with core/full tags |
| `shell/.bin/install-tools-apk` | New — Alpine with core/full tags |
| `shell/.bin/install-symlinks` | Updated — replaces ln -s loop with stow |
| `shell/.bin/install-all` | Updated — new ordering, drops source builds, passes tag |
| `shell/.bin/jzd-install` | Updated — pass `$2` through to tools and all subcommands |
