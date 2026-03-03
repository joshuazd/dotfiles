# Bootstrap Install Script Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a `install.sh` at the repo root that bootstraps a fresh machine via
`bash -c "$(curl -fsSL ...)"`, and document it in the README.

**Architecture:** Thin wrapper — `install.sh` checks for git, clones the repo to
`$DOTFILES` (default `~/dotfiles`), then delegates to the existing `install-tools core`
and `install-symlinks` scripts. No logic duplicated from platform scripts.

**Tech Stack:** POSIX sh, git, existing shell/.bin scripts

---

### Task 1: Create install.sh

**Files:**
- Create: `install.sh`

**Step 1: Create the script**

`install.sh`:

```sh
#!/bin/sh
set -o errexit -o nounset

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
REPO="https://github.com/joshuazd/dotfiles.git"

if ! command -v git >/dev/null 2>&1; then
    echo "install: git is required" >&2
    exit 1
fi

if [ -d "$DOTFILES" ]; then
    echo "Dotfiles already present at $DOTFILES — skipping clone."
else
    git clone "$REPO" "$DOTFILES"
fi

"$DOTFILES/shell/.bin/install-tools" core
"$DOTFILES/shell/.bin/install-symlinks"

echo "Done. Open a new shell to pick up the changes."
```

**Step 2: Make executable and verify syntax**

```bash
chmod +x install.sh
bash -n install.sh && echo "syntax ok"
```

Expected: `syntax ok`

**Step 3: Verify the script is reachable at the raw GitHub URL (after push)**

The URL will be:
```
https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh
```

(Verify after push in Task 3.)

**Step 4: Commit**

```bash
git add install.sh
git commit -m "install: add bootstrap install.sh for fresh machine setup"
```

---

### Task 2: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Read the current README**

```bash
head -20 README.md
```

**Step 2: Add Quick Install section**

Insert a `## Quick Install` section immediately after the CI badge block (lines 3-5)
and before `## Overview` (line 9). The section should read:

```markdown
## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh)"
```

To clone to a custom path (default is `~/dotfiles`):

```bash
DOTFILES=~/.dotfiles bash -c "$(curl -fsSL https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh)"
```
```

**Step 3: Verify README renders correctly**

```bash
head -25 README.md
```

Expected: badges → blank line → `## Quick Install` → code blocks → blank line → `## Overview`

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add Quick Install one-liner to README"
```

---

### Task 3: Push and verify

**Step 1: Push**

```bash
git push
```

**Step 2: Verify raw URL is accessible**

```bash
curl -fsSL https://raw.githubusercontent.com/joshuazd/dotfiles/master/install.sh | head -5
```

Expected: first 5 lines of the script (shebang + set + DOTFILES=...).
