#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  PANEL="${BATS_TEST_DIRNAME}/../vigil-panel"
}

@test "a portrait client gets a strip across the top" {
  export TMUX_STUB_DISPLAY="40 60"
  run "${PANEL}"
  [ "${status}" -eq 0 ]
  run tmux_call_args "split-window"
  [[ "${output}" == *"-vb"* ]]
  [[ "${output}" == *"10"* ]]
}

@test "a landscape client gets a column on the left" {
  export TMUX_STUB_DISPLAY="40 200"
  run "${PANEL}"
  [ "${status}" -eq 0 ]
  run tmux_call_args "split-window"
  [[ "${output}" == *"-hb"* ]]
  [[ "${output}" == *"40"* ]]
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
  [[ "${output}" == *"60"* ]]
  [[ "${output}" != *$'\x1f'"40"* ]]
}

@test "the panel runs vigil in panel mode" {
  export TMUX_STUB_DISPLAY="40 200"
  run "${PANEL}"
  run tmux_call_args "split-window"
  [[ "${output}" == *"vigil --panel"* ]]
}

@test "the new pane is marked and set to close on exit" {
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_SPLIT_PANE="%7"
  run "${PANEL}"
  [ "${status}" -eq 0 ]

  # Assert on the specific set-option call rather than the flattened log: the
  # marker and the pane id must land on the same invocation, not merely both
  # appear somewhere in the run.
  run tmux_call_args_matching "set-option" "@vigil_panel"
  [[ "${output}" == *"%7"* ]]
  [[ "${output}" == *"@vigil_panel"* ]]

  run tmux_call_args_matching "set-option" "remain-on-exit"
  [[ "${output}" == *"%7"* ]]
  [[ "${output}" == *"remain-on-exit"* ]]
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
