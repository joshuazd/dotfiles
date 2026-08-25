.PHONY: test lint

# SC2155 and SC2001 are excluded to match scripts/scripts: the
# `local x="$(...)"` and `sed`-instead-of-parameter-expansion idioms are
# conventions across these hooks, not defects.
SHELLCHECK_FLAGS := -e SC2155 -e SC2001

test:
	bats tests/

lint:
	shellcheck $(SHELLCHECK_FLAGS) *.sh
