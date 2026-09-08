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

# The negation of assert_arg_after, for asserting that a flag was NOT given a
# particular value. Reads the same stdin.
refute_arg_after() {
  ! assert_arg_after "${1}" "${2}"
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

setup_fzf_stub() {
  export FZF_STUB_LOG="${BATS_TEST_TMPDIR}/fzf-calls.log"
  : > "${FZF_STUB_LOG}"
  export FZF_STUB_ROWS_LOG="${BATS_TEST_TMPDIR}/fzf-rows.log"
  : > "${FZF_STUB_ROWS_LOG}"
  export PATH="${BATS_TEST_DIRNAME}/stubs:${PATH}"
}

# The rows a picker offered, which arrive on stdin rather than in argv. An
# assertion about what was on offer has to read this, not fzf_args.
fzf_rows() {
  cat "${FZF_STUB_ROWS_LOG}"
}

# Print the argv of the first fzf invocation, one argument per line.
# tr needs the octal escape: it does not understand \x.
fzf_args() {
  head -1 "${FZF_STUB_LOG}" | tr '\037' '\n'
}

# Assert fzf was never invoked.
refute_fzf_called() {
  [ ! -s "${FZF_STUB_LOG}" ]
}

# Generic argv-recording stubs, for tools a test must observe but must not
# actually run: gh, short, ts, and the worktree scripts. The checked-in stubs
# in tests/stubs/ exist for fzf and tmux, whose behavior tests depend on;
# these are throwaway recorders and are generated rather than committed.
#
# Deliberately not used for git. lib/git.sh and the worktree scripts lean on
# real git behavior, and a real `git init` in BATS_TEST_TMPDIR is both faster
# to reason about and harder to get subtly wrong than a stub.
setup_cmd_stubs() {
  export CMD_STUB_LOG="${BATS_TEST_TMPDIR}/cmd-calls.log"
  : > "${CMD_STUB_LOG}"
  export CMD_STUB_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${CMD_STUB_BIN}"
  # Front of PATH: these must win over anything real that is installed.
  export PATH="${CMD_STUB_BIN}:${PATH}"
}

# Install an argv-recording stub.
# Arguments:
#   name          command name to shadow
#   stdout        text the stub prints (optional, may be multi-line)
#   exit-status   status the stub exits with (optional, default 0)
stub_cmd() {
  local name="${1}"
  local out="${2-}"
  local exit_status="${3-0}"
  local script="${CMD_STUB_BIN}/${name}"
  local out_file="${CMD_STUB_BIN}/${name}.stdout"

  # The canned output goes in a sibling file rather than being interpolated
  # into the script. Embedding it would need quoting that survives newlines,
  # backslashes and quotes all at once, which is exactly the kind of thing
  # that fails silently and makes a test pass for the wrong reason.
  printf '%s' "${out}" > "${out_file}"

  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -o nounset\n'
    printf 'printf %%s %s >> "${CMD_STUB_LOG}"\n' "$(printf '%q' "${name}")"
    printf 'for a in ${1+"${@}"}; do printf "\\x1f%%s" "${a}" >> "${CMD_STUB_LOG}"; done\n'
    printf 'printf "\\n" >> "${CMD_STUB_LOG}"\n'
    printf 'if [ -s %s ]; then cat %s; printf "\\n"; fi\n' \
      "$(printf '%q' "${out_file}")" "$(printf '%q' "${out_file}")"
    printf 'exit %s\n' "${exit_status}"
  } > "${script}"
  chmod +x "${script}"
}

cmd_calls() {
  cat "${CMD_STUB_LOG}"
}

# Anchored at both ends: a bare name must match the whole line, or `gh` would
# match every `gh-review` call and refute_cmd_called would never fire.
assert_cmd_called() {
  grep -q -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}"
}

refute_cmd_called() {
  ! grep -q -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}"
}

# Argv of the first invocation, one argument per line, the command name first.
# tr needs the octal escape: it does not understand \x.
cmd_call_args() {
  grep -m1 -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}" \
    | tr '\037' '\n'
}

# 1-based log line of the first invocation, so a test can assert that one
# command ran before another.
cmd_call_index() {
  grep -n -m1 -e "^${1}${TMUX_STUB_SEP}" -e "^${1}\$" "${CMD_STUB_LOG}" \
    | cut -d: -f1
}
