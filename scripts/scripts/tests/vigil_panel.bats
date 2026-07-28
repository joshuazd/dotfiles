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
  # The size must be the argument after -l, not merely present: without -l
  # tmux takes it as the pane command and the panel never starts.
  printf '%s\n' "${output}" | assert_arg_after "-l" "10"
}

@test "a landscape client gets a column on the left" {
  export TMUX_STUB_DISPLAY="40 200"
  run "${PANEL}"
  [ "${status}" -eq 0 ]
  run tmux_call_args "split-window"
  [[ "${output}" == *"-hb"* ]]
  printf '%s\n' "${output}" | assert_arg_after "-l" "40"
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
  #
  # Exact-line matches, not substrings, and -p above all. Without -p tmux sets
  # a *session* option; #{@vigil_panel} then inherits pane to window to
  # session, panel_pane's `$2 == "1"` matches the first pane in the window -
  # the Claude pane - and the next `prefix p` runs kill-pane on that instead
  # of on the panel.
  run tmux_call_args_matching "set-option" "@vigil_panel"
  printf '%s\n' "${output}" | grep -Fxq -- "-p"
  printf '%s\n' "${output}" | grep -Fxq -- "%7"
  printf '%s\n' "${output}" | grep -Fxq -- "@vigil_panel"
  [ "$(printf '%s\n' "${output}" | tail -n1)" = "1" ]

  run tmux_call_args_matching "set-option" "remain-on-exit"
  printf '%s\n' "${output}" | grep -Fxq -- "-p"
  printf '%s\n' "${output}" | grep -Fxq -- "%7"
  printf '%s\n' "${output}" | grep -Fxq -- "remain-on-exit"
  [ "$(printf '%s\n' "${output}" | tail -n1)" = "off" ]
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
