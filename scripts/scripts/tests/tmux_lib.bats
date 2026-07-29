#!/usr/bin/env bats

load helper

setup() {
  setup_tmux_stub
  source "${BATS_TEST_DIRNAME}/../lib/tmux.sh"
}

@test "session_name_from_title strips tmux-unsafe characters" {
  run session_name_from_title "SC" "12345" "Emit metrics: for v1.2 'now'"
  [ "${status}" -eq 0 ]
  [ "${output}" = "SC-12345 Emit metrics for v12 now" ]
}

@test "session_name_from_title truncates at a word boundary" {
  run session_name_from_title "SC" "12345" "Refactor the entire authentication subsystem end to end"
  [ "${status}" -eq 0 ]
  [ "${#output}" -le 50 ]
  [[ "${output}" != *" " ]]
}

@test "tmux stub records invocations" {
  tmux display-message -p "hello world"
  run tmux_calls
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"display-message"* ]]
  [[ "${output}" == *"hello world"* ]]
}

@test "refute_tmux_subcommand fails when the subcommand was used" {
  tmux send-keys -t target "echo hi" Enter
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -ne 0 ]
}

@test "assert_tmux_subcommand fails when the subcommand was not used" {
  run assert_tmux_subcommand "respawn-pane"
  [ "${status}" -ne 0 ]
}

@test "tmux_call_args splits arguments containing spaces" {
  tmux respawn-pane -k -t "=SC-1 demo:claude.1" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
  [[ "${output}" == *"claude --model opus"* ]]
  [ "$(printf '%s' "${output}" | grep -c .)" -eq 5 ]
}

@test "launch_claude_in_pane respawns the pane instead of sending keys" {
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -eq 0 ]
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"-k"* ]]
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
  [[ "${output}" == *"/tmp/wt"* ]]
}

@test "launch_claude_in_pane keeps a shell alive after claude exits" {
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"claude --model opus; exec "* ]]
}

@test "launch_claude_in_pane targets the marked pane by id" {
  export TMUX_STUB_LIST_PANES="%4 0
%5 1"
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"%5"* ]]
  [[ "${output}" != *":claude.1"* ]]
}

@test "launch_claude_in_pane falls back to the positional target for older sessions" {
  export TMUX_STUB_LIST_PANES=""
  launch_claude_in_pane "SC-1 demo" "/tmp/wt" "claude --model opus"
  run tmux_call_args "respawn-pane"
  [[ "${output}" == *"=SC-1 demo:claude.1"* ]]
}

@test "setup_secondary_pane sends its command to the pane it just made" {
  export TMUX_STUB_DISPLAY="120"
  export TMUX_STUB_SPLIT_PANE="%8"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "send-keys"
  [[ "${output}" == *"%8"* ]]
  [[ "${output}" != *":claude.2"* ]]
}

@test "setup_secondary_pane returns focus to the claude pane by id" {
  export TMUX_STUB_DISPLAY="120"
  export TMUX_STUB_LIST_PANES="%4 1"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "select-pane"
  [[ "${output}" == *"%4"* ]]
}

@test "create_tmux_session marks the claude pane" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args_matching "set-option" "@vigil_claude"
  # Exact-line matches, not substrings: the target check must not be
  # satisfiable by a differently-scoped or differently-windowed set-option
  # call, and the value check must land on the actual last argument rather
  # than an incidental "1" elsewhere in the line (e.g. inside "SC-1").
  printf '%s\n' "${output}" | grep -Fxq -- "-p"
  printf '%s\n' "${output}" | grep -Fxq -- "=SC-1 demo:claude"
  printf '%s\n' "${output}" | grep -Fxq -- "@vigil_claude"
  [ "$(printf '%s\n' "${output}" | tail -n1)" = "1" ]
}

@test "create_tmux_session launches claude without send-keys" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  run refute_tmux_subcommand "send-keys"
  [ "${status}" -eq 0 ]
  run tmux_call_args "respawn-pane"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"claude --model opus"* ]]
}

@test "create_tmux_session with no claude command does not respawn" {
  create_tmux_session "SC-1 demo" "/tmp/wt" true ""
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
}

@test "create_tmux_session leaves an existing session's claude alone" {
  export TMUX_STUB_HAS_SESSION=0
  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand "new-session"
  [ "${status}" -eq 0 ]
}

# A stand-in for git-worktree-session that exits with the status given as $1,
# so run_worktree_popup's handling of it can be exercised without a worktree.
_fake_session_script() {
  local exit_status="${1}"
  local script="${BATS_TEST_TMPDIR}/fake-session-script"
  printf '#!/usr/bin/env bash\nexit %s\n' "${exit_status}" > "${script}"
  chmod +x "${script}"
  printf '%s' "${script}"
}

@test "run_worktree_popup carries SESSION_EXISTED out of the popup" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --detached --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
}

@test "run_worktree_popup keeps the status through the interactive prompt" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --detached \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo" < /dev/null
  [ "${status}" -eq "${SESSION_EXISTED}" ]
}

@test "run_worktree_popup still switches to a session that already existed" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script "${SESSION_EXISTED}")"

  run run_worktree_popup --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq "${SESSION_EXISTED}" ]
  run assert_tmux_subcommand "switch-client"
  [ "${status}" -eq 0 ]
}

@test "run_worktree_popup reports a failing popup and does not switch" {
  export DISPATCH_IN_POPUP=1
  local script
  script="$(_fake_session_script 1)"

  run run_worktree_popup --non-interactive \
    "${BATS_TEST_TMPDIR}" "${script}" "feature/x" "SC-1 demo"
  [ "${status}" -eq 1 ]
  run refute_tmux_subcommand "switch-client"
  [ "${status}" -eq 0 ]
}

# Drives git-worktree-session itself rather than a stand-in, so the real
# ordering is exercised: git-worktree-new runs before create_tmux_session and
# hard-fails on an existing directory, which on a re-dispatch would mask
# SESSION_EXISTED behind a generic failure and never tell the caller to leave
# the running Claude alone. The worktree directory is pre-created here because
# that is what a re-dispatch actually looks like.
@test "git-worktree-session reports SESSION_EXISTED without creating a worktree" {
  export TMUX_STUB_HAS_SESSION=0

  local repo="${BATS_TEST_TMPDIR}/repo"
  mkdir -p "${repo}" "${BATS_TEST_TMPDIR}/wt"
  git -C "${repo}" init --quiet

  cd "${repo}"
  run "${BATS_TEST_DIRNAME}/../git-worktree-session" \
    --detached --dir-name wt --session-name "SC-1 demo" feature/x

  [ "${status}" -eq "${SESSION_EXISTED}" ]
  [[ "${output}" != *"Creating worktree"* ]]
  [[ "${output}" != *"Failed to create worktree"* ]]
  run refute_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand "new-session"
  [ "${status}" -eq 0 ]
}

@test "git-worktree-session still creates a worktree when only the directory exists" {
  export TMUX_STUB_HAS_SESSION=1

  local repo="${BATS_TEST_TMPDIR}/repo2"
  mkdir -p "${repo}" "${BATS_TEST_TMPDIR}/wt2"
  git -C "${repo}" init --quiet

  cd "${repo}"
  run "${BATS_TEST_DIRNAME}/../git-worktree-session" \
    --detached --dir-name wt2 --session-name "SC-2 demo" feature/y

  [ "${status}" -ne 0 ]
  [ "${status}" -ne "${SESSION_EXISTED}" ]
  [[ "${output}" == *"Creating worktree"* ]]
}

@test "worktree_prompt_file resolves under the worktree git dir" {
  local wt="${BATS_TEST_TMPDIR}/wt"
  mkdir -p "${wt}"
  git -C "${wt}" init --quiet
  export TMUX_STUB_DISPLAY="${wt}"

  run worktree_prompt_file "SC-1 demo"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"/vigil-launch-prompt.txt" ]]
  [ -d "$(dirname "${output}")" ]
}

@test "worktree_prompt_file fails when the pane path is not a git dir" {
  export TMUX_STUB_DISPLAY="${BATS_TEST_TMPDIR}/not-a-repo"
  mkdir -p "${TMUX_STUB_DISPLAY}"

  run worktree_prompt_file "SC-1 demo"
  [ "${status}" -ne 0 ]
  [ -z "${output}" ]
}

@test "worktree_prompt_file queries the claude window pane path" {
  local wt="${BATS_TEST_TMPDIR}/wt2"
  mkdir -p "${wt}"
  git -C "${wt}" init --quiet
  export TMUX_STUB_DISPLAY="${wt}"

  worktree_prompt_file "SC-1 demo"
  run tmux_call_args "display-message"
  [[ "${output}" == *"=SC-1 demo:claude"* ]]
  [[ "${output}" == *"pane_current_path"* ]]
}

@test "the stub answers pane_width separately from the client size" {
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_PANE_WIDTH="160"
  run tmux display-message -p '#{pane_width}'
  [ "${output}" = "160" ]
  run tmux display-message -p '#{client_height} #{client_width}'
  [ "${output}" = "40 200" ]
}

@test "an explicitly empty client size stays empty" {
  # The no-client case. A :- default would silently substitute dimensions and
  # the fallback branch could never be reached from a test.
  export TMUX_STUB_DISPLAY=""
  run tmux display-message -p '#{client_height} #{client_width}'
  [ "${output}" = "" ]
}

@test "tmux_call_index reports call order" {
  tmux split-window -t first
  tmux respawn-pane -t second
  first_index="$(tmux_call_index "split-window" "first")"
  second_index="$(tmux_call_index "respawn-pane" "second")"
  [ "${first_index}" -lt "${second_index}" ]
}

@test "tmux_call_index is empty for a call that never happened" {
  run tmux_call_index "kill-pane" "anything"
  [ "${output}" = "" ]
}

@test "panel_geometry falls back to a left column with no client" {
  # A session created detached has no client to measure. The arithmetic in
  # the auto branch is an error on an empty string under errexit, so this is
  # a crash, not a wrong answer.
  export TMUX_STUB_DISPLAY=""
  run panel_geometry
  [ "${status}" -eq 0 ]
  [ "${output}" = "-hb 40" ]
}

@test "panel_geometry measures a portrait client" {
  export TMUX_STUB_DISPLAY="40 60"
  run panel_geometry
  [ "${output}" = "-vb 10" ]
}

@test "panel_geometry measures a landscape client" {
  export TMUX_STUB_DISPLAY="40 200"
  run panel_geometry
  [ "${output}" = "-hb 40" ]
}

@test "add_vigil_panel splits the window it is given" {
  export TMUX_STUB_DISPLAY="40 200"
  run add_vigil_panel "=SC-1 demo:claude"
  [ "${status}" -eq 0 ]
  run tmux_call_args "split-window"
  printf '%s\n' "${output}" | assert_arg_after "-t" "=SC-1 demo:claude"
  printf '%s\n' "${output}" | assert_arg_after "-l" "40"
  [[ "${output}" == *"vigil --panel"* ]]
}

@test "add_vigil_panel marks the pane it created" {
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_SPLIT_PANE="%7"
  add_vigil_panel "=SC-1 demo:claude"

  run tmux_call_args_matching "set-option" "@vigil_panel"
  printf '%s\n' "${output}" | grep -Fxq -- "-p"
  printf '%s\n' "${output}" | grep -Fxq -- "%7"
  [ "$(printf '%s\n' "${output}" | tail -n1)" = "1" ]

  run tmux_call_args_matching "set-option" "remain-on-exit"
  printf '%s\n' "${output}" | grep -Fxq -- "-p"
  printf '%s\n' "${output}" | grep -Fxq -- "%7"
  [ "$(printf '%s\n' "${output}" | tail -n1)" = "off" ]
}

@test "add_vigil_panel reports a failed split instead of marking nothing" {
  # errexit is disabled for the whole function when it is called on the left
  # of ||, which every caller does. Without an explicit check the failure
  # falls through and set-option runs against an empty target.
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_SPLIT_FAILS=1
  run add_vigil_panel "=SC-1 demo:claude"
  [ "${status}" -ne 0 ]
  run refute_tmux_subcommand "set-option"
  [ "${status}" -eq 0 ]
}

@test "setup_secondary_pane measures the pane it is about to split" {
  # window_width does not shrink when a 40-column panel appears, but the pane
  # being split does. Measuring the window picks -h for a pane that is really
  # 160 wide.
  export TMUX_STUB_PANE_WIDTH="160"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args_matching "display-message" "pane_width"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"pane_width"* ]]
  run refute_tmux_subcommand_matching "display-message" "window_width"
  [ "${status}" -eq 0 ]
}

@test "a narrow claude pane splits vertically" {
  # TMUX_STUB_DISPLAY is set wide on purpose: if setup_secondary_pane ever
  # regresses back to querying window_width, the stub answers from this var
  # and the split comes out -h, so this test actually catches that mistake
  # instead of passing by accident.
  export TMUX_STUB_PANE_WIDTH="160"
  export TMUX_STUB_DISPLAY="300"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "split-window"
  [[ "${output}" == *"-v"* ]]
}

@test "a wide claude pane still splits horizontally" {
  export TMUX_STUB_PANE_WIDTH="200"
  setup_secondary_pane "SC-1 demo" "nit"
  run tmux_call_args "split-window"
  [[ "${output}" == *"-h"* ]]
}

@test "a new session gets a panel in its claude window" {
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args_matching "split-window" "vigil --panel"
  [ "${status}" -eq 0 ]
  printf '%s\n' "${output}" | assert_arg_after "-t" "=SC-1 demo:claude"
}

@test "panel_auto false leaves the session unpanelled" {
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  export VIGIL_STUB_PANEL_AUTO="false"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run refute_tmux_subcommand_matching "split-window" "vigil --panel"
  [ "${status}" -eq 0 ]
}

@test "a missing vigil leaves the session unpanelled and working" {
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  # A prefix strip of the stub dir is not enough: everything else on the
  # inherited PATH survives, including ~/.local/bin, which on a dev machine
  # holds a real installed vigil. Replace PATH wholesale instead, so vigil is
  # genuinely absent rather than merely not the stub.
  mkdir -p "${BATS_TEST_TMPDIR}/tmuxonly"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/tmux" "${BATS_TEST_TMPDIR}/tmuxonly/tmux"
  export PATH="${BATS_TEST_TMPDIR}/tmuxonly:/usr/bin:/bin"
  run command -v vigil
  [ "${status}" -ne 0 ]

  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  [ "${status}" -eq 0 ]
  run refute_tmux_subcommand_matching "split-window" "vigil --panel"
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
}

@test "a failed panel does not abort session creation" {
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  export TMUX_STUB_SPLIT_FAILS=1
  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
}

@test "the panel is created before the nit split" {
  # Order is the point: setup_secondary_pane measures the claude pane, so the
  # panel's 40 columns must already be gone when it looks. Panel second would
  # leave it reading full width, which is the bug the pane_width change
  # exists to remove.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "nit" "claude --model opus"
  panel_at="$(tmux_call_index "split-window" "vigil --panel")"
  # "nit" itself never appears in the split-window argv - setup_secondary_pane
  # sends the pane_command via a later send-keys, not as a split-window
  # argument. pane_current_path is the -c flag unique to that split, so it is
  # what actually identifies the nit split's position in the log.
  nit_at="$(tmux_call_index "split-window" "pane_current_path")"
  claude_at="$(tmux_call_index "respawn-pane" "claude --model opus")"
  [ -n "${panel_at}" ]
  [ -n "${nit_at}" ]
  [ "${panel_at}" -lt "${nit_at}" ]
  [ "${nit_at}" -lt "${claude_at}" ]
}

@test "a new session is created at the calling client's size" {
  # tmux sizes a detached session's window to default-size, 80x24. The panel
  # is split at an absolute 40 columns, so in an 80-column window it takes
  # half, and tmux redistributes proportionally on attach: measured at 175
  # columns on a real 350-column client before this fix.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="90 350"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args "new-session"
  [ "${status}" -eq 0 ]
  # Adjacency, not mere presence: tmux reads the value from the argument
  # after the flag, and 350 appears elsewhere in argv the moment anything
  # else carries it.
  printf '%s\n' "${output}" | assert_arg_after "-x" "350"
  printf '%s\n' "${output}" | assert_arg_after "-y" "90"
}

@test "a new session with no client omits the size flags" {
  # A cron or Chrome dispatch from outside tmux has no client to measure.
  # Passing -x/-y with empty values would be a tmux usage error and would
  # cost the user a working session, so the flags have to be absent.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY=""
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args "new-session"
  [ "${status}" -eq 0 ]
  # Counted rather than negated. A bare `! ... | grep` here would be a
  # middle statement, which bash exempts from errexit and whose status bats
  # then discards, so it could never fail the test.
  [ "$(printf '%s\n' "${output}" | grep -cFx -e "-x" -e "-y")" -eq 0 ]
}

@test "the session size and the panel size come from one query" {
  # panel_geometry sizes the panel against the client and create_tmux_session
  # sizes the window against the client. Two separate queries could disagree
  # about what "no client" means, so both go through client_dimensions.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="90 350"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args "new-session"
  printf '%s\n' "${output}" | assert_arg_after "-x" "350"
  # 350 wide and 90 tall is landscape, so the panel is a 40-column strip
  # inside a window that is now genuinely 350 wide.
  run tmux_call_args_matching "split-window" "vigil --panel"
  printf '%s\n' "${output}" | assert_arg_after "-l" "40"
}

@test "a present but broken vigil warns instead of failing silently" {
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  export VIGIL_STUB_FAILS=1
  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" "claude --model opus"
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"vigil config get panel_auto failed"* ]]
  run refute_tmux_subcommand_matching "split-window" "vigil --panel"
  [ "${status}" -eq 0 ]
  run assert_tmux_subcommand "respawn-pane"
  [ "${status}" -eq 0 ]
}

@test "an absent vigil says nothing" {
  # The other half of the pair above: absent is not an error condition, so it
  # must not produce a warning. Without the command -v guard both cases look
  # the same to the user.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  mkdir -p "${BATS_TEST_TMPDIR}/tmuxonly"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/tmux" "${BATS_TEST_TMPDIR}/tmuxonly/tmux"
  export PATH="${BATS_TEST_TMPDIR}/tmuxonly:/usr/bin:/bin"
  run command -v vigil
  [ "${status}" -ne 0 ]

  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"vigil config get panel_auto failed"* ]]
}

@test "the panel gate honours VIGIL_BIN" {
  # add_vigil_panel launches ${VIGIL_BIN:-vigil}. A gate that asks bare vigil
  # decides with a different binary than it runs, and with no vigil on PATH
  # the override is silently inert on the create path while prefix p still
  # honours it.
  export TMUX_STUB_HAS_SESSION=1
  export TMUX_STUB_DISPLAY="40 200"
  mkdir -p "${BATS_TEST_TMPDIR}/tmuxonly"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/tmux" "${BATS_TEST_TMPDIR}/tmuxonly/tmux"
  export PATH="${BATS_TEST_TMPDIR}/tmuxonly:/usr/bin:/bin"
  run command -v vigil
  [ "${status}" -ne 0 ]

  export VIGIL_BIN="${BATS_TEST_DIRNAME}/stubs/vigil"
  create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  run tmux_call_args_matching "split-window" "${VIGIL_BIN} --panel"
  [ "${status}" -eq 0 ]
}

@test "an existing session is not panelled again" {
  export TMUX_STUB_HAS_SESSION=0
  run create_tmux_session "SC-1 demo" "/tmp/wt" true "" ""
  [ "${status}" -eq 3 ]
  run refute_tmux_subcommand "split-window"
  [ "${status}" -eq 0 ]
}
