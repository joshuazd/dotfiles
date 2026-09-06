#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  setup_tmux_stub
  setup_cmd_stubs
  SC_PICK="${BATS_TEST_DIRNAME}/../sc-pick"
  export SCRIPTS_PKG_DIR="${CMD_STUB_BIN}"
  # What `short ... | jq -r ...` produces: id, state, name. Both halves of the
  # pipeline are stubbed - short because it is a network call, jq because the
  # short stub emits the finished rows rather than the JSON jq would parse.
  SC_LIST="$(printf 'sc-101\tIn Progress\tFix the thing\nsc-102\tBacklog\tAdd the other')"
}

stub_listing() {
  stub_cmd short "${SC_LIST}"
  stub_cmd jq "${SC_LIST}"
}

@test "claim hands the id to shortcut-claim" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  run cmd_call_args shortcut-claim
  [ "${lines[1]}" = "sc-101" ]
}

@test "implement hands the id to shortcut-implement" {
  stub_listing
  stub_cmd shortcut-implement
  export FZF_STUB_SELECTION=$'sc-102\tsc-102  Backlog  Add the other'
  run "${SC_PICK}" implement
  [ "${status}" -eq 0 ]
  run cmd_call_args shortcut-implement
  [ "${lines[1]}" = "sc-102" ]
}

@test "worktree hands the id to shortcut-worktree" {
  stub_listing
  stub_cmd shortcut-worktree
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" worktree
  [ "${status}" -eq 0 ]
  run cmd_call_args shortcut-worktree
  [ "${lines[1]}" = "sc-101" ]
}

# `short story <id> -O` opens a browser. `short story <id> -o <name>` ASSIGNS
# owners. The two differ by one letter's case and one of them mutates the
# story, so browse must never reach for the lowercase form.
@test "browse opens the story with the uppercase flag" {
  stub_listing
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" browse
  [ "${status}" -eq 0 ]
  run cmd_calls
  [[ "${output}" == *"-O"* ]]
}

@test "the listing filters to unfinished stories owned by the user" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run cmd_call_args short
  [[ "${output}" == *"owner:%self% !is:done"* ]]
}

# The listing must go through `short s`, never `short story`, which mutates.
@test "the listing uses the search subcommand" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run cmd_call_args short
  [ "${lines[1]}" = "s" ]
}

@test "rows carry the id, state and name" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run fzf_rows
  [[ "${output}" == *"sc-101"* ]]
  [[ "${output}" == *"In Progress"* ]]
  [[ "${output}" == *"Fix the thing"* ]]
}

@test "the id is hidden and the summary is displayed" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_SELECTION=$'sc-101\tsc-101  In Progress  Fix the thing'
  run "${SC_PICK}" claim
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "an empty list says so and runs nothing" {
  stub_cmd short ""
  stub_cmd jq ""
  stub_cmd shortcut-claim
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No stories assigned to you."* ]]
  refute_cmd_called shortcut-claim
}

@test "a failing short reads as an empty list, not an error" {
  stub_cmd short "" 1
  stub_cmd jq ""
  stub_cmd shortcut-claim
  run "${SC_PICK}" claim
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No stories assigned to you."* ]]
  refute_cmd_called shortcut-claim
}

@test "escaping runs nothing" {
  stub_listing
  stub_cmd shortcut-claim
  export FZF_STUB_ABORT=1
  run "${SC_PICK}" claim
  [ "${status}" -eq 97 ]
  refute_cmd_called shortcut-claim
}

@test "an unknown verb is a usage error" {
  run "${SC_PICK}" frobnicate
  [ "${status}" -eq 2 ]
}

@test "a missing verb is a usage error" {
  run "${SC_PICK}"
  [ "${status}" -eq 2 ]
}

@test "--help exits 0" {
  run "${SC_PICK}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}
