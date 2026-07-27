.PHONY: test lint

test:
	bats tests/

lint:
	shellcheck common.sh lib/*.sh dispatch dispatch-from-chrome gh-review \
		shortcut-implement git-worktree-session git-worktree-new
