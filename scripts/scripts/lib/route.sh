#!/usr/bin/env bash
#
# lib/route.sh - Per-invocation model and reasoning routing for dispatch
#
# A Haiku 4.5 classifier inspects PR/story signals and picks `model`,
# `reasoning`, and `exec_tier` for the launched `claude` session. On
# classifier failure or timeout, the helpers emit a conservative default
# (opus + xhigh + exec_tier=sonnet) so dispatch never blocks.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/route.sh"

[[ -n "${__LIB_ROUTE_LOADED:-}" ]] && return
readonly __LIB_ROUTE_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

readonly _ROUTE_FALLBACK_JSON='{"model":"opus","reasoning":"xhigh","exec_tier":"sonnet","rationale":"classifier-fallback"}'
readonly _ROUTE_CLASSIFIER_MODEL="claude-haiku-4-5-20251001"
readonly _ROUTE_TIMEOUT_SECS=30
readonly _ROUTE_DEBUG_LOG="${CLAUDE_ROUTE_DEBUG_LOG:-/tmp/route-debug.log}"

#######################################
# When CLAUDE_ROUTE_DEBUG=1, append a labeled blob to the debug log.
# Arguments:
#   label   — short tag
#   content — text to record (may be multi-line)
#######################################
_route_debug() {
  [ "${CLAUDE_ROUTE_DEBUG:-0}" = "1" ] || return 0
  local label="${1}"
  local content="${2}"
  {
    printf '\n=== %s :: %s ===\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${label}"
    printf '%s\n' "${content}"
  } >> "${_ROUTE_DEBUG_LOG}" 2>/dev/null || true
}

#######################################
# Map a tier name to a Claude CLI model ID.
# Opus 4.7 and Sonnet 4.6 include the 1M context window at standard pricing,
# so we always opt in via the `[1m]` suffix. Haiku 4.5 stays at standard.
# Arguments:
#   tier — opus | sonnet | haiku
# Outputs:
#   Writes the model ID to stdout
# Returns:
#   0 on success, 1 on unknown tier
#######################################
model_id() {
  local tier="${1}"

  case "${tier}" in
    opus)   printf "claude-opus-4-7[1m]" ;;
    sonnet) printf "claude-sonnet-4-6[1m]" ;;
    haiku)  printf "claude-haiku-4-5-20251001" ;;
    *)
      error "Unknown tier: ${tier}"
      return 1
      ;;
  esac
}

#######################################
# Build a manual-override routing JSON when --tier / --reasoning are supplied.
# Derives exec_tier as one tier below model (opus→sonnet, sonnet→sonnet, haiku→haiku).
# Arguments:
#   tier      — opus | opus-1m | sonnet | haiku
#   reasoning — xhigh | high | medium | low (default: xhigh)
# Outputs:
#   Routing JSON to stdout
#######################################
#######################################
# Parse routing JSON into 4 tab-delimited fields: model, reasoning, exec_tier, rationale.
# All jq stderr is suppressed; on parse failure, the conservative fallback values
# are emitted so the caller never has to handle errors.
# Arguments:
#   route_json — JSON string produced by classify_* or manual_route
# Outputs:
#   "<model>\t<reasoning>\t<exec_tier>\t<rationale>" to stdout
#######################################
parse_route() {
  local route_json="${1}"
  local parsed=""
  parsed="$(printf '%s' "${route_json}" \
    | jq -r '[.model // "opus", .reasoning // "xhigh", .exec_tier // "sonnet", .rationale // "no-rationale"] | @tsv' 2>/dev/null)" || parsed=""
  if [ -z "${parsed}" ]; then
    _route_debug "parse_route: invalid JSON, using fallback" "${route_json}"
    parsed=$'opus\txhigh\tsonnet\tclassifier-fallback'
  fi
  printf '%s' "${parsed}"
}

manual_route() {
  local tier="${1}"
  local reasoning="${2:-}"
  local exec_tier
  local default_reasoning

  case "${tier}" in
    opus)   exec_tier="sonnet"; default_reasoning="xhigh" ;;
    sonnet) exec_tier="sonnet"; default_reasoning="high" ;;
    haiku)  exec_tier="haiku";  default_reasoning="medium" ;;
    *)
      error "Unknown tier: ${tier}"
      return 1
      ;;
  esac

  [ -z "${reasoning}" ] && reasoning="${default_reasoning}"

  printf '{"model":"%s","reasoning":"%s","exec_tier":"%s","rationale":"manual override"}' \
    "${tier}" "${reasoning}" "${exec_tier}"
}

#######################################
# System prompt for the classifier pre-pass.
# Arguments:
#   kind — "pr" or "story"
# Outputs:
#   System-prompt text to stdout
#######################################
_classifier_system_prompt() {
  local kind="${1}"
  local shared="You classify engineering tasks for routing to a Claude model. Return strict JSON ONLY — no preamble, no markdown fences, no commentary outside the rationale field.

Default: model=opus, reasoning=xhigh. The user prefers staying on the highest effort their chosen model supports, and is willing to downgrade the model more readily than the effort.

Valid reasoning levels are tied to the model:
- Opus → xhigh or high (NEVER medium or low)
- Sonnet → high or medium (NEVER xhigh, NEVER low)

NEVER emit haiku for model — only opus or sonnet.

exec_tier rule: one tier below model. opus→sonnet, sonnet→sonnet.

Output exactly this JSON shape (single line, no trailing newline):
{\"model\":\"opus|sonnet\",\"reasoning\":\"xhigh|high|medium\",\"exec_tier\":\"opus|sonnet\",\"rationale\":\"one short sentence\"}"

  case "${kind}" in
    pr)
      printf '%s\n\n%s' "${shared}" "Downgrade rules (PR review):
- sonnet + high: ≤3 files changed, OR no production code touched (only specs/docs/ci/config), OR single-purpose well-scoped change
- sonnet + medium: lockfile-only OR generated-file-only OR copy/string-only OR pure dependency bump (e.g. Dependabot)
- Otherwise: opus + xhigh"
      ;;
    story)
      printf '%s\n\n%s' "${shared}" "Downgrade rules (story implement):
- sonnet + high: clearly-scoped UI tweak, single-component change, error-message wording, config flag flip, simple migration, isolated bug fix
- sonnet + medium: chore / cleanup / spec-only stories with no production behavior change, pure doc/copy edits
- Otherwise: opus + xhigh"
      ;;
    *)
      error "Unknown classifier kind: ${kind}"
      return 1
      ;;
  esac
}

#######################################
# Call the Haiku classifier and return its routing JSON.
# On timeout, error, or invalid output, prints the conservative fallback.
# Arguments:
#   kind    — "pr" or "story"
#   payload — JSON string of signals to send as the user message
# Outputs:
#   Routing JSON to stdout (always — fallback on any failure)
#######################################
_classify() {
  local kind="${1}"
  local payload="${2}"

  local sys_prompt
  if ! sys_prompt="$(_classifier_system_prompt "${kind}")"; then
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  _route_debug "classifier payload (${kind})" "${payload}"

  local user_prompt="Classify this ${kind} payload and return strict JSON only (no preamble, no markdown fences):

${payload}"

  # Minimal flags that keep OAuth auth working. (--bare requires ANTHROPIC_API_KEY
  # and skips keychain, which times out on OAuth users.)
  local result
  if ! result="$(timeout "${_ROUTE_TIMEOUT_SECS}" claude -p "${user_prompt}" \
      --model "${_ROUTE_CLASSIFIER_MODEL}" \
      --output-format json \
      --no-session-persistence \
      --disable-slash-commands \
      --setting-sources user \
      --tools "" \
      --append-system-prompt "${sys_prompt}" 2>/dev/null)"; then
    warn "classifier: timed out or failed, using fallback"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  _route_debug "classifier raw result (${kind})" "${result}"

  local routing
  routing="$(printf '%s' "${result}" | jq -r '.result // empty' 2>/dev/null)"

  # Strip whitespace and possible code fences the model may emit despite instructions.
  routing="${routing#\`\`\`json}"
  routing="${routing#\`\`\`}"
  routing="${routing%\`\`\`}"
  routing="$(printf '%s' "${routing}" | tr -d '\n')"

  if ! printf '%s' "${routing}" | jq -e 'has("model") and has("reasoning") and has("exec_tier")' >/dev/null 2>&1; then
    warn "classifier: invalid output, using fallback"
    _route_debug "classifier: validation failed (${kind})" "${routing}"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  _route_debug "classifier final routing (${kind})" "${routing}"
  printf '%s' "${routing}"
}

#######################################
# Classify a GitHub PR. Fetches signals via `gh` and runs the Haiku classifier.
# Arguments:
#   pr_ref — PR number, #N, or URL (whatever `gh pr view` accepts)
# Outputs:
#   Routing JSON to stdout (fallback on any failure)
#######################################
classify_pr() {
  local pr_ref="${1}"
  local pr_json

  if ! pr_json="$(gh pr view "${pr_ref}" --json title,body,files,labels,headRefName 2>/dev/null)"; then
    warn "classifier: failed to fetch PR ${pr_ref}, using fallback"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  local payload
  payload="$(printf '%s' "${pr_json}" | jq -c '
    (.files // []) as $files |
    (.labels // []) as $labels |
    {
      title: (.title // ""),
      body: ((.body // "") | .[0:2000]),
      file_count: ($files | length),
      additions: ([$files[].additions] | add // 0),
      deletions: ([$files[].deletions] | add // 0),
      file_paths: [$files[].path],
      labels: [$labels[].name],
      branch: (.headRefName // "")
    }' 2>/dev/null)"

  if [ -z "${payload}" ]; then
    warn "classifier: could not build PR payload, using fallback"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  _classify pr "${payload}"
}

#######################################
# Classify a Shortcut story. Fetches signals via `short` and runs the classifier.
# Arguments:
#   story_id — numeric story ID
# Outputs:
#   Routing JSON to stdout (fallback on any failure)
#######################################
classify_story() {
  local story_id="${1}"
  local story_json

  if ! story_json="$(short story "${story_id}" --format '%j' -q 2>/dev/null)"; then
    warn "classifier: failed to fetch story ${story_id}, using fallback"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  local payload
  payload="$(printf '%s' "${story_json}" | jq -c '{
    title: (.name // ""),
    description: ((.description // "") | .[0:2000]),
    story_type: (.story_type // ""),
    labels: [.labels[]?.name],
    epic_name: (.epic.name // "")
  }' 2>/dev/null)"

  if [ -z "${payload}" ] || [ "${payload}" = "null" ]; then
    warn "classifier: could not parse story ${story_id} JSON, using fallback"
    printf '%s' "${_ROUTE_FALLBACK_JSON}"
    return 0
  fi

  _classify story "${payload}"
}

#######################################
# Build the `claude` invocation string for tmux send-keys.
# Embeds a <routing-hint> block via --append-system-prompt so the in-session
# skill can read it.
# Arguments:
#   tier            — opus | sonnet | haiku  (model tier the classifier picked)
#   reasoning       — xhigh | high | medium | low
#   exec_tier       — opus | sonnet | haiku
#   rationale       — one-line classifier reason (shell-safe; printf %q escapes it)
#   slash_command   — e.g. "/review-pr 123" or "/implement 12345"
#   extra_flags...  — optional, e.g. "--permission-mode" "plan"
# Outputs:
#   The full shell command string to stdout
#######################################
claude_launch_cmd() {
  local tier="${1}"
  local reasoning="${2}"
  local exec_tier="${3}"
  local rationale="${4}"
  local slash_command="${5}"
  shift 5
  local -a extra_flags=("${@}")

  local model
  model="$(model_id "${tier}")" || return 1

  local hint="<routing-hint>
model: ${tier}
reasoning: ${reasoning}
exec_tier: ${exec_tier}
rationale: ${rationale}
</routing-hint>"

  local hint_quoted
  hint_quoted="$(printf '%q' "${hint}")"

  # Quote the model arg: ID may contain [1m] which is a bash glob pattern.
  local cmd="claude --model $(printf '%q' "${model}") --effort ${reasoning}"
  local flag
  for flag in "${extra_flags[@]}"; do
    cmd+=" $(printf '%q' "${flag}")"
  done
  cmd+=" --append-system-prompt ${hint_quoted} -- $(printf '%q' "${slash_command}")"

  printf '%s' "${cmd}"
}
