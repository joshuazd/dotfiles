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
