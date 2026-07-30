#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  export STUB_LOG="${BATS_TEST_TMPDIR}/calls.log"
  export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
  mkdir -p "${BATS_TEST_TMPDIR}/bin"

  # osascript stub: report a Shortcut URL, record activations.
  cat > "${BATS_TEST_TMPDIR}/bin/osascript" <<'STUB'
#!/usr/bin/env bash
printf 'osascript %s\n' "${*}" >> "${STUB_LOG}"
if printf '%s' "${*}" | grep -q 'active tab'; then
  printf 'https://app.shortcut.com/ws/story/12345/a-title\n'
fi
STUB
  chmod +x "${BATS_TEST_TMPDIR}/bin/osascript"

  cat > "${BATS_TEST_TMPDIR}/bin/vigil" <<'STUB'
#!/usr/bin/env bash
printf 'vigil %s\n' "${*}" >> "${STUB_LOG}"
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
  [ "$(tmux_call_args_matching 'display-popup' | grep -c .)" -eq 0 ]
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
