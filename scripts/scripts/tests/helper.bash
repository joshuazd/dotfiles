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
