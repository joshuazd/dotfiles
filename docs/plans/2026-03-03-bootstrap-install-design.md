# Bootstrap Install Script Design

**Date:** 2026-03-03
**Status:** Approved

## Goal

A single `install.sh` at the repo root that a user can run on a fresh machine via
`bash -c "$(curl -fsSL ...)"` to clone the dotfiles and install core tools + symlinks
without any manual steps.

## Architecture

**Thin wrapper:** `install.sh` handles only bootstrap concerns (clone the repo), then
delegates entirely to the existing `install-tools` and `install-symlinks` scripts.
No logic is duplicated from the platform scripts.

```
install.sh
  → git clone $REPO $DOTFILES   (skipped if $DOTFILES already exists)
  → shell/.bin/install-tools core
  → shell/.bin/install-symlinks
```

## install.sh

Lives at the dotfiles root. Approximately 20 lines.

- `$DOTFILES` env var sets clone destination; defaults to `~/dotfiles`
- Checks that `git` is available (only hard prereq — `curl` is already present)
- Clones the repo; skips silently if `$DOTFILES` directory already exists (idempotent)
- Execs `install-tools core` then `install-symlinks` from the cloned repo
- Prints "open a new shell to pick up the changes" on success
- No prompts, no sudo of its own (platform scripts handle privilege escalation)

## README.md

Add a **Quick Install** section immediately below the CI badges and above the Overview
section. Include two code blocks:

1. Default install (`~/dotfiles`)
2. Custom path via `DOTFILES` env var

## Files Changed

| File | Change |
|------|--------|
| `install.sh` | New — bootstrap script |
| `README.md` | Add Quick Install section near top |
