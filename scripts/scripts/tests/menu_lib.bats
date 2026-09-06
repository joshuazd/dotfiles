#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  source "${BATS_TEST_DIRNAME}/../lib/menu.sh"
}

@test "a short list fits a tall client" {
  export TMUX_STUB_CLIENT_HEIGHT=40
  run menu_fits 6
  [ "${status}" -eq 0 ]
}

@test "a list taller than the client does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits 60
  [ "${status}" -ne 0 ]
}

# The boundary is the whole point: one row short blanks the menu rather than
# shrinking it, so the comparison has to include the chrome.
@test "the chrome counts against the height" {
  export TMUX_STUB_CLIENT_HEIGHT=10
  run menu_fits $((10 - MENU_CHROME_ROWS))
  [ "${status}" -eq 0 ]
  run menu_fits $((10 - MENU_CHROME_ROWS + 1))
  [ "${status}" -ne 0 ]
}

# An unmeasurable height must not be treated as unlimited.
@test "an unmeasurable client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT=""
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "a non-numeric client height does not fit" {
  export TMUX_STUB_CLIENT_HEIGHT="not-a-number"
  run menu_fits 1
  [ "${status}" -ne 0 ]
}

@test "menu_client_height reports what tmux says" {
  export TMUX_STUB_CLIENT_HEIGHT=33
  run menu_client_height
  [ "${output}" = "33" ]
}
