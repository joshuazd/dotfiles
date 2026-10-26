#!/usr/bin/env bats

load helper

setup() {
  bats_require_minimum_version 1.5.0
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

@test "the complex tier of each kind is fable at medium, and nothing routes to xhigh" {
  local kind
  for kind in pr story; do
    _route_has_pair "${kind}" fable medium
    run ! _route_has_pair "${kind}" opus xhigh
    run ! _route_has_pair "${kind}" fable xhigh
  done
}

@test "both kinds default to opus at high" {
  [ "$(_route_default_json pr | jq -r "[.model, .reasoning] | join(\"+\")")" = "opus+high" ]
  [ "$(_route_default_json story | jq -r "[.model, .reasoning] | join(\"+\")")" = "opus+high" ]
}

@test "manual opus tier defaults to high effort" {
  run manual_route opus
  [ "$(jq -r .reasoning <<<"${output}")" = "high" ]
}

@test "fable needs no [1m] suffix" {
  run model_id fable
  [ "${output}" = "fable" ]
}

@test "manual fable tier defaults to medium effort" {
  run manual_route fable
  [ "${status}" -eq 0 ]
  [ "$(jq -r .reasoning <<<"${output}")" = "medium" ]
}

@test "a classifier verdict off the matrix falls back to the default" {
  claude() { printf '{"result":"{\\"model\\":\\"fable\\",\\"reasoning\\":\\"xhigh\\",\\"confidence\\":\\"high\\",\\"rationale\\":\\"x\\"}"}'; }
  timeout() { shift; "${@}"; }
  run _classify story "{}"
  [ "$(jq -r "[.model, .reasoning] | join(\"+\")" <<<"${output##*$'\n'}")" = "opus+high" ]
}

@test "a classifier verdict on the matrix passes through" {
  claude() { printf '{"result":"{\\"model\\":\\"fable\\",\\"reasoning\\":\\"medium\\",\\"confidence\\":\\"high\\",\\"rationale\\":\\"x\\"}"}'; }
  timeout() { shift; "${@}"; }
  run _classify story "{}"
  [ "$(jq -r "[.model, .reasoning] | join(\"+\")" <<<"${output}")" = "fable+medium" ]
}
