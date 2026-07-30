#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  export STUB_LOG="${BATS_TEST_TMPDIR}/calls.log"
  export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
  mkdir -p "${BATS_TEST_TMPDIR}/bin"

  # osascript stub: report a Shortcut URL, record activations. ensure_client's
  # AppleScript calls (the "activate" one-liner and the create-window/tab
  # heredoc) pass no argv at all - the heredoc script arrives on stdin - so
  # argv alone can't tell them apart from each other or from a call that never
  # happened. When called with zero args, also append stdin to the log so
  # tests can assert on which AppleScript actually ran.
  cat > "${BATS_TEST_TMPDIR}/bin/osascript" <<'STUB'
#!/usr/bin/env bash
printf 'osascript %s\n' "${*}" >> "${STUB_LOG}"
if [ "${#}" -eq 0 ]; then
  cat >> "${STUB_LOG}"
fi
if printf '%s' "${*}" | grep -q 'active tab'; then
  printf 'https://app.shortcut.com/ws/story/12345/a-title\n'
fi
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/osascript"

  cat > "${BATS_TEST_TMPDIR}/bin/vigil" <<'STUB'
#!/usr/bin/env bash
printf 'vigil %s\n' "${*}" >> "${STUB_LOG}"
exit "${VIGIL_STUB_EXIT:-0}"
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/vigil"

  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}/portal"
}

@test "dispatch-from-chrome submits the Chrome URL to vigil dispatch" {
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  [ "$(grep -c 'vigil dispatch' "${STUB_LOG}")" -eq 1 ]
  [ "$(grep -c -- "--cwd ${HOME}/portal" "${STUB_LOG}")" -eq 1 ]
  [ "$(grep -c 'story/12345' "${STUB_LOG}")" -eq 1 ]
}

@test "dispatch-from-chrome opens no popup" {
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  # tmux_call_args_matching takes a subcommand and a pattern; passing only one
  # only works because bats doesn't run under nounset. An empty pattern
  # matches any argv for the subcommand, which is what "opens no popup" needs.
  [ "$(tmux_call_args_matching 'display-popup' '' | grep -c .)" -eq 0 ]
}

@test "dispatch-from-chrome honours --repo" {
  mkdir -p "${HOME}/vigil"
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome" --repo vigil
  [ "${status}" -eq 0 ]
  [ "$(grep -c -- "--cwd ${HOME}/vigil" "${STUB_LOG}")" -eq 1 ]
}

@test "dispatch-from-chrome rejects a URL it cannot route" {
  cat > "${BATS_TEST_TMPDIR}/bin/osascript" <<'STUB'
#!/usr/bin/env bash
printf 'osascript %s\n' "${*}" >> "${STUB_LOG}"
if printf '%s' "${*}" | grep -q 'active tab'; then
  printf 'https://example.com/nothing\n'
fi
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/osascript"
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "$(grep -c 'vigil dispatch' "${STUB_LOG}")" -eq 0 ]
  [ "$(grep -c 'display notification' "${STUB_LOG}")" -ge 1 ]
}

@test "dispatch-from-chrome still dispatches when no tmux server is running" {
  # get_tmux_session's pipeline opens with `tmux list-sessions`, which fails
  # outright with no server up at all (distinct from a server with no
  # sessions). Under errexit + pipefail, an unguarded assignment from that
  # pipeline aborts the script before vigil dispatch ever runs - exactly the
  # no-client-anywhere case ensure_client exists to handle.
  export TMUX_STUB_LIST_SESSIONS_FAILS=1
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  [ "$(grep -c 'vigil dispatch' "${STUB_LOG}")" -eq 1 ]
}

@test "dispatch-from-chrome surfaces a vigil dispatch failure" {
  export VIGIL_STUB_EXIT=1
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 1 ]
  [ "$(grep -c 'Dispatch failed' "${STUB_LOG}")" -ge 1 ]
}

# ensure_client is not sourceable in isolation - dispatch-from-chrome calls
# main unconditionally at the bottom of the file - so its branches are
# exercised through full runs of the script, distinguished by the tmux
# session/client state fed in through the stub.
@test "ensure_client just activates iTerm2 when the session already has a client" {
  export TMUX_STUB_LIST_SESSIONS="100 mysession"
  export TMUX_STUB_LIST_CLIENTS="/dev/ttys009"
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  [ "$(grep -c 'activate' "${STUB_LOG}")" -eq 1 ]
  [ "$(grep -c 'create window\|create tab' "${STUB_LOG}")" -eq 0 ]
}

@test "ensure_client just activates iTerm2 when there is no tmux session anywhere" {
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  [ "$(grep -c 'activate' "${STUB_LOG}")" -eq 1 ]
  [ "$(grep -c 'create window\|create tab' "${STUB_LOG}")" -eq 0 ]
}

@test "ensure_client opens an iTerm2 window and reports a timeout for a detached session" {
  export TMUX_STUB_LIST_SESSIONS="100 mysession"
  # TMUX_STUB_LIST_CLIENTS left unset: no client ever attaches, so the
  # create-window/tab branch runs and the wait loop rides out its real 5s
  # deadline before ensure_client gives up and returns.
  run "${BATS_TEST_DIRNAME}/../dispatch-from-chrome"
  [ "${status}" -eq 0 ]
  # The dumped AppleScript source has separate lines for the create-window
  # and create-tab branches, so a plain line count is not 1 - assert
  # presence, not an exact count.
  [ "$(grep -c 'create window\|create tab' "${STUB_LOG}")" -ge 1 ]
  [ "$(grep -c 'Timed out waiting for a tmux client to attach' "${STUB_LOG}")" -eq 1 ]
  # ensure_client fails soft: the dispatch still happens even though no
  # client ever showed up to receive the closing switch-client.
  [ "$(grep -c 'vigil dispatch' "${STUB_LOG}")" -eq 1 ]
}
