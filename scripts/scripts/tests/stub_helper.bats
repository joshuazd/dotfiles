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

# The recorder must not swallow the command name of a different stub that
# happens to share a prefix.
@test "a prefix of another stub name does not match it" {
  stub_cmd gh
  stub_cmd gh-review
  gh-review 1
  refute_cmd_called gh
}
