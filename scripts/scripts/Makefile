.PHONY: test lint

# Every bash script in the package. dispatch-bar is a compiled binary and
# migrate-clean is ruby, so both stay out.
SHELL_SCRIPTS := common.sh $(wildcard lib/*.sh) \
	claude-trust dispatch dispatch-from-chrome \
	gh-review gh-review-poll gh-worktree \
	git-worktree-cleanup git-worktree-done git-worktree-new git-worktree-session \
	portal-open short-story-md shortcut-claim shortcut-implement shortcut-worktree \
	ts vigil-panel worktree-status

# -x plus the source paths lets shellcheck follow the lib/ sources instead of
# reporting SC1091 on every one. SC2155 is excluded because the
# `readonly SCRIPT_DIR="$(cd ...)"` idiom is a convention across this package.
SHELLCHECK_FLAGS := -x -P SCRIPTDIR -P SCRIPTDIR/lib -e SC2155

test:
	bats tests/

lint:
	shellcheck $(SHELLCHECK_FLAGS) $(SHELL_SCRIPTS)
