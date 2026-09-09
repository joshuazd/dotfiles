#!/usr/bin/env bats

load helper

setup() {
  setup_cmd_stubs
}

@test "a stubbed command records its argv" {
  stub_cmd fakecmd
  fakecmd one two
  assert_cmd_called fakecmd
  run cmd_call_args fakecmd
  [ "${lines[0]}" = "fakecmd" ]
  [ "${lines[1]}" = "one" ]
  [ "${lines[2]}" = "two" ]
}

@test "a stubbed command emits the stdout it was given" {
  stub_cmd fakecmd "hello there"
  run fakecmd
  [ "${output}" = "hello there" ]
}

@test "a stubbed command can be given an exit status" {
  stub_cmd fakecmd "" 3
  run fakecmd
  [ "${status}" -eq 3 ]
}

@test "an uncalled stub refutes" {
  stub_cmd fakecmd
  refute_cmd_called fakecmd
}

@test "arguments containing spaces stay one argument" {
  stub_cmd fakecmd
  fakecmd "two words"
  run cmd_call_args fakecmd
  [ "${lines[1]}" = "two words" ]
}

@test "multi-line stdout survives" {
  stub_cmd fakecmd "$(printf 'a\nb')"
  run fakecmd
  [ "${lines[0]}" = "a" ]
  [ "${lines[1]}" = "b" ]
}

@test "call order is recoverable" {
  stub_cmd first
  stub_cmd second
  first
  second
  [ "$(cmd_call_index first)" -lt "$(cmd_call_index second)" ]
}

# A stub called with no arguments at all still has to record itself, or a
# refute_cmd_called on it passes when the command did in fact run.
@test "a no-argument call is still recorded" {
  stub_cmd fakecmd
  fakecmd
  assert_cmd_called fakecmd
}

# Two stubs in a pipeline run CONCURRENTLY and append to the same log. A
# recorder that wrote a printf per argument interleaved them into one garbled
# line - `short<US>s<US>-qjq<US>...` - which is how sc_pick.bats' assertions
# about `short s -q ...` failed on the macOS CI runner and nowhere else. The
# repeat count is what makes this deterministic: a single pass wins the race
# often enough to pass by luck.
@test "two stubs in a pipeline do not interleave their argv" {
  stub_cmd producer
  stub_cmd consumer
  local i
  for i in $(seq 1 40); do
    : > "${CMD_STUB_LOG}"
    producer one "two words" | consumer -r 'a b' >/dev/null
    [ "$(cmd_call_args producer)" = "$(printf 'producer\none\ntwo words')" ]
    [ "$(cmd_call_args consumer)" = "$(printf 'consumer\n-r\na b')" ]
  done
}

# The recorder must not swallow the command name of a different stub that
# happens to share a prefix.
@test "a prefix of another stub name does not match it" {
  stub_cmd gh
  stub_cmd gh-review
  gh-review 1
  refute_cmd_called gh
}

# with_timeout is not a stub, but it lives in the same helper and has the same
# problem if it is wrong: a silent CI-only failure. It stands in for
# timeout(1), which the macos-latest image does not have.
@test "with_timeout passes the command's own status through" {
  run with_timeout 5 bash -c 'echo hi; exit 2'
  [ "${status}" -eq 2 ]
  [ "${output}" = "hi" ]
}

@test "with_timeout reports 124 for a command that overruns" {
  run with_timeout 1 bash -c 'sleep 30'
  [ "${status}" -eq 124 ]
}
