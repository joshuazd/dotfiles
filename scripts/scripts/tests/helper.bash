# The stub joins argv with the unit separator. This must be an actual 0x1f
# byte via ANSI-C quoting: "\x1f" inside double quotes stays a literal
# backslash-x-1-f, and grep would read it as the characters x1f, so every
# pattern below would silently fail to match and refute_* would always pass.
readonly TMUX_STUB_SEP=$'\x1f'

setup_tmux_stub() {
  export TMUX_STUB_LOG="${BATS_TEST_TMPDIR}/tmux-calls.log"
  : > "${TMUX_STUB_LOG}"
  export PATH="${BATS_TEST_DIRNAME}/stubs:${PATH}"
  export TMUX="fake-socket,0,0"
  export TMUX_STUB_HAS_SESSION=1
}

tmux_calls() {
  cat "${TMUX_STUB_LOG}"
}

# Assert that at least one recorded invocation used the given subcommand.
assert_tmux_subcommand() {
  local subcommand="${1}"
  grep -q "^${subcommand}${TMUX_STUB_SEP}" "${TMUX_STUB_LOG}"
}

# Assert that no recorded invocation used the given subcommand.
refute_tmux_subcommand() {
  local subcommand="${1}"
  ! grep -q "^${subcommand}${TMUX_STUB_SEP}" "${TMUX_STUB_LOG}"
}

# Print the full argv of the first invocation of the given subcommand, one
# argument per line. tr needs the octal escape: it does not understand \x.
tmux_call_args() {
  local subcommand="${1}"
  grep -m1 "^${subcommand}${TMUX_STUB_SEP}" "${TMUX_STUB_LOG}" | tr '\037' '\n'
}

# Assert that the argument immediately following flag is exactly value, given
# tmux_call_args output on stdin.
#
# Adjacency is the whole point. tmux reads a split's size from the argument
# after -l, so a substring check for the size alone is satisfied by the size
# appearing anywhere in argv - including as the pane command, which is how
# tmux reads it once -l is gone.
assert_arg_after() {
  local flag="${1}"
  local value="${2}"
  local prev='' line
  while IFS= read -r line; do
    if [ "${prev}" = "${flag}" ] && [ "${line}" = "${value}" ]; then
      return 0
    fi
    prev="${line}"
  done
  return 1
}

# Like tmux_call_args, but narrowed to the first invocation of the given
# subcommand whose argv also contains the given substring. Needed when a
# subcommand is called more than once with different arguments (e.g. two
# set-option calls) and an assertion must land on the right one rather than
# on whichever call happens to appear first in the log.
tmux_call_args_matching() {
  local subcommand="${1}"
  local pattern="${2}"
  grep -m1 "^${subcommand}${TMUX_STUB_SEP}.*${pattern}" "${TMUX_STUB_LOG}" | tr '\037' '\n'
}

# Print the 1-based log line number of the first invocation matching both the
# subcommand and the pattern. Every other helper throws position away, and
# ordering between two calls of the same subcommand cannot be asserted
# without it.
tmux_call_index() {
  local subcommand="${1}"
  local pattern="${2}"
  grep -n -m1 -e "^${subcommand}${TMUX_STUB_SEP}.*${pattern}" "${TMUX_STUB_LOG}" \
    | cut -d: -f1
}

# Assert that no invocation of the subcommand also matched the pattern.
# refute_tmux_subcommand is too coarse when a subcommand is used for several
# different queries in one run.
refute_tmux_subcommand_matching() {
  local subcommand="${1}"
  local pattern="${2}"
  ! grep -q -e "^${subcommand}${TMUX_STUB_SEP}.*${pattern}" "${TMUX_STUB_LOG}"
}
