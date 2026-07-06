#!/bin/sh
set -eu

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
REPO="https://github.com/joshuazd/dotfiles.git"

if ! command -v git >/dev/null 2>&1; then
    echo "install: git is required" >&2
    exit 1
fi

if [ -d "$DOTFILES" ]; then
    echo "Dotfiles already present at $DOTFILES - skipping clone."
else
    git clone "$REPO" "$DOTFILES"
fi

"$DOTFILES/shell/.bin/install-tools" core

# install-tools may have just installed Homebrew; make its bin visible to the
# symlink step (stow lives there) without requiring a new shell.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

"$DOTFILES/shell/.bin/install-symlinks"

echo "Done. Open a new shell to pick up the changes."
