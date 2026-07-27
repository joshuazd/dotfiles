#!/usr/bin/env bats

load helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/route.sh"
}

@test "claude_launch_cmd inlines the prompt when no prompt file is set" {
  run claude_launch_cmd "opus" "high" "because" "/implement 1" ""
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"--append-system-prompt"* ]]
  [[ "${output}" == *"routing-hint"* ]]
  [[ "${output}" != *'$(cat '* ]]
}

@test "claude_launch_cmd writes the prompt to CLAUDE_PROMPT_FILE and reads it back" {
  export CLAUDE_PROMPT_FILE="${BATS_TEST_TMPDIR}/prompt.txt"
  run claude_launch_cmd "opus" "high" "because" "/implement 1" ""
  [ "${status}" -eq 0 ]
  [[ "${output}" == *'--append-system-prompt "$(cat '* ]]
  [[ "${output}" == *"prompt.txt"* ]]
  [[ "${output}" != *"routing-hint"* ]]
  [ -f "${CLAUDE_PROMPT_FILE}" ]
  grep -q "routing-hint" "${CLAUDE_PROMPT_FILE}"
}

@test "claude_launch_cmd writes the extra system block to the prompt file" {
  export CLAUDE_PROMPT_FILE="${BATS_TEST_TMPDIR}/prompt.txt"
  run claude_launch_cmd "opus" "high" "because" "/implement 1" "<execution-default>
multi
line
</execution-default>"
  [ "${status}" -eq 0 ]
  grep -q "execution-default" "${CLAUDE_PROMPT_FILE}"
  grep -q "^multi$" "${CLAUDE_PROMPT_FILE}"
  grep -q "^line$" "${CLAUDE_PROMPT_FILE}"
}

@test "claude_launch_cmd still quotes the model id and slash command" {
  export CLAUDE_PROMPT_FILE="${BATS_TEST_TMPDIR}/prompt.txt"
  run claude_launch_cmd "opus" "high" "because" "/implement 1" ""
  [[ "${output}" == *"--effort high"* ]]
  [[ "${output}" == *'-- /implement\ 1'* ]]
}
