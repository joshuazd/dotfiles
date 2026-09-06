#!/usr/bin/env bats

load helper

setup() {
  setup_fzf_stub
  source "${BATS_TEST_DIRNAME}/../lib/picker.sh"
  ROWS="${BATS_TEST_TMPDIR}/rows"
  printf 'run-me\tAlpha\nrun-other\tBravo\n' > "${ROWS}"
}

@test "pick_one returns the selected row" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha'
  run pick_one < "${ROWS}"
  [ "${status}" -eq 0 ]
  [ "${output}" = $'run-me\tAlpha' ]
}

@test "pick_one displays the last field by default" {
  run pick_one < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--with-nth" "-1"
}

@test "pick_one requests a centered modal by default" {
  run pick_one < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--tmux" "center,80%,70%"
}

@test "pick_one honors --size" {
  run pick_one --size "bottom,40%" < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--tmux" "bottom,40%"
}

# The user's ~/.fzfrc sets a global --preview that shells out to a file
# previewer on {}. Picker rows are arbitrary records, not filenames, so it must
# be off unless the caller asked for one.
@test "preview is disabled unless the caller asks for one" {
  run pick_one < "${ROWS}"
  run fzf_args
  [[ "${output}" == *"--no-preview"* ]]
}

@test "an explicit --preview wins over the default" {
  run pick_one --preview "echo hi" < "${ROWS}"
  run fzf_args
  [[ "${output}" != *"--no-preview"* ]]
  printf '%s\n' "${output}" | assert_arg_after "--preview" "echo hi"
}

@test "--preview-window is passed through alongside --preview" {
  run pick_one --preview "echo hi" --preview-window "down,3,border-top" < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--preview-window" "down,3,border-top"
}

# --style belongs to the user's ~/.fzfrc: the per-section borders and labels
# are their aesthetic. --padding is spacing, and a picker in a popup sized to
# its contents cannot afford two rows of it.
@test "the picker keeps the user's fzf style but drops its padding" {
  run pick_one < "${ROWS}"
  run fzf_args
  [[ "${output}" != *"--style"* ]]
  printf '%s\n' "${output}" | assert_arg_after "--padding" "0"
}

# A one-cell blank ring outside the border. tmux repaints an overlay's
# outermost cells when a pane flushes a DECSET 2026 frame, and anything drawn
# there tears; blank cells cannot.
@test "a caller can ask for a simpler frame" {
  run pick_one --style default < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--style" "default"
}

@test "the picker leaves a blank margin outside the border" {
  run pick_one < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--margin" "1,1,0,1"
}

# An empty --size must render inline instead of spawning a nested popup.
# Inside an existing display-popup, --tmux makes fzf exit 0 having printed
# nothing, so the selection is lost and the caller sees "nothing picked".
@test "an empty --size renders inline and passes no --tmux" {
  run pick_one --size "" < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" != *"--tmux"* ]]
  [[ "${output}" == *"--height"* ]]
}

@test "pick_one passes prompt and header through" {
  run pick_one --prompt "Pick> " --header "Choose one" < "${ROWS}"
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--prompt" "Pick> "
  run fzf_args
  printf '%s\n' "${output}" | assert_arg_after "--header" "Choose one"
}

@test "pick_one does not enable multi-select" {
  run pick_one < "${ROWS}"
  run fzf_args
  [[ "${output}" != *"--multi"* ]]
}

@test "pick_many enables multi-select and select-all bindings" {
  run pick_many < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" == *"--multi"* ]]
  printf '%s\n' "${output}" | assert_arg_after "--bind" "ctrl-a:select-all,ctrl-d:deselect-all"
}

@test "pick_many returns every selected row" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha\nrun-other\tBravo'
  run pick_many < "${ROWS}"
  [ "${status}" -eq 0 ]
  [ "$(printf '%s' "${output}" | grep -c .)" -eq 2 ]
}

@test "empty stdin returns PICKER_NO_SELECTION without launching fzf" {
  : > "${BATS_TEST_TMPDIR}/empty"
  run pick_one < "${BATS_TEST_TMPDIR}/empty"
  [ "${status}" -eq 1 ]
  run refute_fzf_called
  [ "${status}" -eq 0 ]
}

@test "aborting the picker returns PICKER_NO_SELECTION" {
  export FZF_STUB_ABORT=1
  run pick_one < "${ROWS}"
  [ "${status}" -eq 1 ]
}

@test "a missing fzf returns PICKER_UNAVAILABLE" {
  # PICKER_PATH_DIRS="" disables the bootstrap. Without it the bootstrap
  # appends /opt/homebrew/bin, where the real fzf lives, and this test could
  # never observe a missing fzf no matter what PATH it set.
  PICKER_PATH_DIRS="" PATH="/usr/bin:/bin" run pick_one < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "an unknown option returns PICKER_UNAVAILABLE" {
  run pick_one --nonsense < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "a trailing --prompt with no value returns PICKER_UNAVAILABLE" {
  run pick_one --prompt < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "a trailing --size with no value returns PICKER_UNAVAILABLE" {
  run pick_one --size < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "fzf exiting 2 returns PICKER_UNAVAILABLE" {
  export FZF_STUB_EXIT=2
  run pick_one < "${ROWS}"
  [ "${status}" -eq 2 ]
}

@test "picker_bootstrap_path is idempotent" {
  PATH="/usr/bin:/bin"
  picker_bootstrap_path
  local once="${PATH}"
  picker_bootstrap_path
  [ "${PATH}" = "${once}" ]
}

# An empty list closes the popup instantly with no explanation unless the
# caller supplies one. "No open PRs." is the difference between a working
# menu and one that looks broken.
@test "--empty-message replaces the default empty-list warning" {
  run pick_one --empty-message "No open PRs." < /dev/null
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"No open PRs."* ]]
  [[ "${output}" != *"nothing to pick from"* ]]
}

@test "--empty-message does not invoke fzf" {
  run pick_one --empty-message "No open PRs." < /dev/null
  refute_fzf_called
}

@test "without --empty-message an empty list keeps the default warning" {
  run pick_one < /dev/null
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"nothing to pick from"* ]]
}

@test "--empty-message requires a value" {
  run pick_one --empty-message < /dev/null
  [ "${status}" -eq 2 ]
}

@test "--empty-message is not passed through to fzf" {
  export FZF_STUB_SELECTION=$'run-me\tAlpha'
  run pick_one --empty-message "unused" < "${ROWS}"
  [ "${status}" -eq 0 ]
  run fzf_args
  [[ "${output}" != *"--empty-message"* ]]
}
