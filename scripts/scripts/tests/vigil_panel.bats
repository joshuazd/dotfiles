#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  PANEL="${BATS_TEST_DIRNAME}/../vigil-panel"
}

@test "the boundary case counts as landscape" {
  # height*2 == width is not portrait: the rule is strictly greater.
  export TMUX_STUB_DISPLAY="50 100"
  run "${PANEL}"
  run tmux_call_args "split-window"
  [[ "${output}" == *"-hb"* ]]
}

@test "an orientation option overrides the measurement" {
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_PANEL_ORIENTATION="top"
  run "${PANEL}"
  run tmux_call_args "split-window"
  [[ "${output}" == *"-vb"* ]]
}

@test "a size option overrides the default" {
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_PANEL_SIZE="60"
  run "${PANEL}"
  run tmux_call_args "split-window"
  printf '%s\n' "${output}" | assert_arg_after "-l" "60"
  # And the default it overrode is nowhere in argv. An exact-line match:
  # tmux_call_args has already split argv onto one line per argument, so the
  # separator-anchored substring check this replaces could never match.
  ! printf '%s\n' "${output}" | grep -Fxq -- "40"
}

@test "the split leaves focus where it was" {
  export TMUX_STUB_DISPLAY="40 200"
  run "${PANEL}"
  run tmux_call_args "split-window"
  [[ "${output}" == *"-d"* ]]
}

@test "toggling again kills the existing panel" {
  # %1 has no second field: an unset @vigil_panel expands to empty in real
  # tmux, never to a literal "0". %2 is a genuinely marked pane.
  export TMUX_STUB_LIST_PANES="%1
%2 1"
  run "${PANEL}"
  [ "${status}" -eq 0 ]
  run tmux_call_args "kill-pane"
  [[ "${output}" == *"%2"* ]]
  run refute_tmux_subcommand "split-window"
  [ "${status}" -eq 0 ]
}

@test "a window with panes but no panel still splits" {
  export TMUX_STUB_DISPLAY="40 200"
  # No second field on either line: neither pane has @vigil_panel set.
  export TMUX_STUB_LIST_PANES="%1
%2"
  run "${PANEL}"
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "split-window"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand "kill-pane"
  [ "${status}" -eq 0 ]
}
