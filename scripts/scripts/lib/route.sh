#!/usr/bin/env bash
#
# lib/route.sh - Per-invocation model and reasoning routing for dispatch
#
# A Haiku 5.5 classifier inspects PR/story signals and picks `model` and
# `reasoning` for the launched `claude` session.
#
# Policy (Opus is only ~1.67x Sonnet/token, so EFFORT is the primary dial, not
# the model — we stay on Opus and ladder effort rather than drop to a weaker
# model):
#   - PR review is a single pass. Effort ladders on what the changed *paths*
#     are (production area → peripheral → generated/lockfile/dep-bump), NOT on
#     file/line counts: opus+high (default) → opus+medium → opus+low. A PR
#     spanning several production areas or touching core code goes to
#     fable+medium, never opus+xhigh.
#   - Story implement always starts in plan mode. Default is opus+high
#     (moderate work); opus+medium (well-scoped) and opus+low (mechanical)
#     ladder effort down. Complex work goes to fable+medium rather than
#     opus+xhigh: Opus at xhigh ran too long and wandered into unrequested
#     work, and Fable at medium reasons better with less. No routed tier, PR
#     or story, runs at xhigh. Routes description-first; `story_type` is
#     weak/secondary.
#   - Moving off the default requires enumerated positive evidence; a thin or
#     ambiguous signal holds at the default (the default is sticky).
#   - The classifier emits a confidence field. A low-confidence verdict — and
#     any classifier failure/timeout — falls back to the per-kind default
#     (`_route_default_json`): pr → opus+high, story → opus+high.
#   - Effort matrix: Opus and Fable accept xhigh|high|medium|low; sonnet/opusplan
#     cap at high and never run low.
#
# The classifier never emits sonnet or opusplan: Sonnet execution traded away
# too much quality for a ~1.67x per-token saving. Both remain reachable only
# through the manual `--tier` override.
#
# THE TIERS LIVE IN ONE PLACE: the `_route_matrix` table. The classifier
# prompt, JSON enums, per-kind default, and the markdown dump all derive from
# it — edit that table to change routing. To see the live matrix:
#   bash lib/route.sh print-matrix
#
# Usage:
#   source "${SCRIPT_DIR}/lib/route.sh"   # as a library
#   bash lib/route.sh print-matrix        # as a CLI (matrix dump only)

[[ -n "${__LIB_ROUTE_LOADED:-}" ]] && return
readonly __LIB_ROUTE_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

readonly _ROUTE_CLASSIFIER_MODEL="claude-haiku-5-5"
readonly _ROUTE_TIMEOUT_SECS=30
readonly _ROUTE_DEBUG_LOG="${CLAUDE_ROUTE_DEBUG_LOG:-/tmp/route-debug.log}"

#######################################
# THE ROUTING MATRIX — single source of truth for tiers.
#
# One row per tier, pipe-delimited (surrounding whitespace is trimmed, so keep
# it aligned for readability):
#   model | effort | role | trigger
#
# `role` is "default" on exactly one row per kind (the sticky tier that
# uncertainty resolves toward) and blank otherwise. `trigger` is the
# natural-language condition the classifier matches against. Rows are listed
# most→least effort.
#
# To change routing, edit THIS table. The classifier prompt, the JSON model/
# effort enums, the per-kind default, and `print-matrix` all derive from it.
# (The effort *capability ceiling* — opus and fable do all four, sonnet/opusplan
# cap at high and never run low — lives in manual_route, since it's a fixed property
# of the models, not policy.)
# Arguments:
#   kind — "pr" or "story"
# Outputs:
#   Pipe-delimited rows to stdout
#######################################
_route_matrix() {
  case "${1}" in
    pr) cat <<'ROWS'
fable    | medium |         | rare: the title, body or paths positively show a change whose correctness hinges on a subtle invariant the reviewer must hold across the whole diff - concurrency / locking / transaction boundaries, authn / authz / tenant isolation, a migration or backfill that rewrites production data, or a change to a state machine or status lifecycle
opus     | high   | default | most reviews, including large or multi-area changes, new classes / modules / data sources that follow an existing pattern, and refactors that move logic between files
opus     | medium |         | changes confined to peripheral paths (spec/, test/, docs/, config/, CI)
opus     | low    |         | generated-only, lockfile-only, copy/string-only, or a pure dependency bump (e.g. Dependabot)
ROWS
      ;;
    story) cat <<'ROWS'
fable    | medium |         | rare: the description positively shows work whose correctness hinges on a subtle invariant that must hold across the whole change - concurrency / locking / transaction boundaries, authn / authz / tenant isolation, a migration or backfill that rewrites production data, or a change to a state machine or status lifecycle
opus     | high   | default | work that still needs real design decisions, or a description too thin to place, including large or multi-subsystem work and new patterns; the catch-all when nothing below clearly applies
opus     | medium |         | the shape of the work is clear from the description and needs no design decisions, even if it spans several files in one subsystem: single-component change, UI tweak, config/flag flip, straightforward migration, isolated bug fix, adding a field / column / endpoint / spec that follows an existing pattern, or a mechanical edit repeated across files
opus     | low    |         | clearly a chore / cleanup / spec-only / pure doc-copy edit with no production behavior change
ROWS
      ;;
    *)
      error "Unknown classifier kind: ${1}"
      return 1
      ;;
  esac
}

#######################################
# Render the matrix rows for a kind as classifier-prompt bullet lines:
#   "- <model> + <effort>[ (DEFAULT)] — <trigger>"
#######################################
_route_rows() {
  _route_matrix "${1}" | awk -F'|' '
    { for (i = 1; i <= 4; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i)
      def = ($3 == "default") ? " (DEFAULT)" : ""
      printf "- %s + %s%s — %s\n", $1, $2, def, $4 }'
}

#######################################
# Emit the default row for a kind as "<model>\t<effort>" (empty if none).
#######################################
_route_default_fields() {
  _route_matrix "${1}" | awk -F'|' '
    { for (i = 1; i <= 3; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i) }
    $3 == "default" { printf "%s\t%s\n", $1, $2; exit }'
}

#######################################
# Distinct values of a column (1=model, 2=effort) for a kind, order-preserving,
# joined with "|" for use in the prompt's JSON-shape enum.
#######################################
_route_distinct() {
  _route_matrix "${1}" | awk -F'|' -v c="${2}" '
    { gsub(/^[ \t]+|[ \t]+$/, "", $c); if (!seen[$c]++) out = out (out ? "|" : "") $c }
    END { print out }'
}

#######################################
# Succeed when <model>+<effort> is a row of the kind's matrix. The JSON enums
# list models and efforts independently, so a verdict can pair them into a
# combination no row allows (e.g. fable+xhigh).
# Arguments:
#   kind, model, effort
#######################################
_route_has_pair() {
  _route_matrix "${1}" | awk -F'|' -v m="${2}" -v e="${3}" '
    { for (i = 1; i <= 2; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i) }
    $1 == m && $2 == e { found = 1; exit }
    END { exit !found }'
}

#######################################
# Per-kind safe default routing JSON, derived from the matrix `default` row.
# This is the tier uncertainty resolves toward: classifier failure or a
# low-confidence verdict lands here, NOT on a cheap downgrade and NOT on a
# blanket over-escalation. A hardcoded last-resort matches the matrix defaults
# (opus+high for both kinds) so the safety net never depends on the table it
# is protecting against.
# Arguments:
#   kind      — "pr" or "story"
#   rationale — optional; defaults to "route-default"
# Outputs:
#   Routing JSON to stdout
#######################################
_route_default_json() {
  local kind="${1}"
  local rationale="${2:-route-default}"
  local model effort
  IFS=$'\t' read -r model effort < <(_route_default_fields "${kind}")

  if [ -z "${model}" ] || [ -z "${effort}" ]; then
    model="opus"
    effort="high"
  fi

  printf '{"model":"%s","reasoning":"%s","rationale":"%s"}' \
    "${model}" "${effort}" "${rationale}"
}

#######################################
# Render the matrix as markdown tables (one per kind). Invoked via the direct
# CLI (`bash lib/route.sh print-matrix`) so docs can be a view of the table
# rather than a hand-copied duplicate.
# Outputs:
#   Markdown to stdout
#######################################
route_print_matrix() {
  local kind
  for kind in pr story; do
    printf '\n### %s\n\n' "${kind}"
    printf '| model | effort | role | trigger |\n'
    printf '| --- | --- | --- | --- |\n'
    _route_matrix "${kind}" | awk -F'|' '
      { for (i = 1; i <= 4; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i)
        printf "| %s | %s | %s | %s |\n", $1, $2, ($3 == "" ? "-" : $3), $4 }'
  done
}

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
# Map a tier name to a Claude CLI model argument.
# Aliases, not pinned IDs, so the CLI always resolves the latest model of each
# tier. Opus and Sonnet include the 1M context window at standard pricing, so we
# always opt in via the `[1m]` suffix; Fable is 1M by default, Haiku has no 1M
# variant.
# Arguments:
#   tier — fable | opus | opusplan | sonnet | haiku
# Outputs:
#   Writes the model argument to stdout
# Returns:
#   0 on success, 1 on unknown tier
#######################################
model_id() {
  local tier="${1}"

  case "${tier}" in
    fable)    printf "fable" ;;
    opus)     printf "opus[1m]" ;;
    opusplan) printf "opusplan" ;;
    sonnet)   printf "sonnet[1m]" ;;
    haiku)    printf "haiku" ;;
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
#   reasoning — xhigh | high | medium | low (default: per tier)
# Outputs:
#   Routing JSON to stdout
#######################################
#######################################
# Parse routing JSON into 3 tab-delimited fields: model, reasoning, rationale.
# All jq stderr is suppressed; on parse failure, the conservative fallback values
# are emitted so the caller never has to handle errors.
# Arguments:
#   route_json — JSON string produced by classify_* or manual_route
# Outputs:
#   "<model>\t<reasoning>\t<rationale>" to stdout
#######################################
parse_route() {
  local route_json="${1}"
  local parsed=""
  parsed="$(printf '%s' "${route_json}" \
    | jq -r '[.model // "opus", .reasoning // "high", .rationale // "no-rationale"] | @tsv' 2>/dev/null)" || parsed=""
  if [ -z "${parsed}" ]; then
    _route_debug "parse_route: invalid JSON, using fallback" "${route_json}"
    parsed=$'opus\thigh\tclassifier-fallback'
  fi
  printf '%s' "${parsed}"
}

manual_route() {
  local tier="${1}"
  local reasoning="${2:-}"
  local default_reasoning

  case "${tier}" in
    fable)    default_reasoning="medium" ;;
    opus)     default_reasoning="high" ;;
    opusplan) default_reasoning="high" ;;
    sonnet)   default_reasoning="high" ;;
    haiku)    default_reasoning="medium" ;;
    *)
      error "Unknown tier: ${tier}"
      return 1
      ;;
  esac

  [ -z "${reasoning}" ] && reasoning="${default_reasoning}"

  # Clamp to the model's supported effort matrix. Opus and Fable accept the full ladder
  # (xhigh|high|medium|low). sonnet/opusplan cap at high (xhigh is Opus-only)
  # and never run low.
  case "${tier}" in
    sonnet|opusplan)
      [ "${reasoning}" = "xhigh" ] && reasoning="high"
      if [ "${reasoning}" = "low" ]; then
        error "reasoning 'low' is not allowed for ${tier}"
        return 1
      fi
      ;;
  esac

  printf '{"model":"%s","reasoning":"%s","rationale":"manual override"}' \
    "${tier}" "${reasoning}"
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

  # Per-kind framing prose. The tier list, default, and JSON enums are derived
  # from _route_matrix below — edit tiers there, not here.
  local task intro signal constraints
  case "${kind}" in
    pr)
      task="GitHub PR review"
      intro="PR review is a single pass with no plan-then-execute split, so opusplan and sonnet are never used here. Most reviews run on Opus, and you pick the reasoning EFFORT to match the work. Fable at medium effort is reserved for the rare PR with a specific named risk; it is NOT the next step up from the default."
      signal="Route on WHAT THE CHANGED FILES ARE (the \`file_paths\` signal), not how many there are — there is no file-count or line-count rule. Set confidence=low when the paths don't clearly indicate scope or the title/body is uninformative."
      constraints="NEVER emit haiku, sonnet, or opusplan. Emit only a model+reasoning pair listed above: fable goes only with medium, and opus never with xhigh. Size, file count, the number of directories or subsystems touched, and new files following an established pattern NEVER qualify for fable on their own. If you cannot name which listed fable risk the PR carries, it is opus+high."
      ;;
    story)
      task="Shortcut story implement"
      intro="The implement flow ALWAYS starts in plan mode: the model writes the plan, the user reviews and accepts, then the same model executes it. Most stories run on Opus, and you pick the reasoning EFFORT to match the work. Fable at medium effort is reserved for the rare story with a specific named risk; it is NOT the next step up from the default. Weaker models are never used."
      signal="PRIMARY SIGNAL: the story DESCRIPTION. Judge complexity from what the description actually says the work entails. \`story_type\` (feature/bug/chore) is a WEAK, SECONDARY signal — a \"bug\" can be a one-line fix or a deadlock, a \"chore\" can be a rename or a migration. Do NOT route on story_type alone. Set confidence=low when the description is thin/ambiguous and you cannot confidently place the story."
      constraints="NEVER emit haiku, sonnet, or opusplan. Emit only a model+reasoning pair listed above: fable goes only with medium, and opus never with xhigh. Size, file count, the number of subsystems touched, and introducing a new pattern NEVER qualify for fable on their own; if you cannot name which listed fable risk the story carries, it is not fable. Judge by whether the APPROACH is already settled by the description, not by how many files it touches — breadth alone is not a reason to escalate. Stay on the default when the description leaves real design decisions open."
      ;;
    *)
      error "Unknown classifier kind: ${kind}"
      return 1
      ;;
  esac

  local rows default_model default_effort models efforts
  rows="$(_route_rows "${kind}")" || return 1
  IFS=$'\t' read -r default_model default_effort < <(_route_default_fields "${kind}")
  models="$(_route_distinct "${kind}" 1)"
  efforts="$(_route_distinct "${kind}" 2)"

  printf '%s' "You classify ${task} tasks for routing to a Claude model. Return strict JSON ONLY — no preamble, no markdown fences, no commentary outside the rationale field.

${intro}

${signal}

DEFAULT: model=${default_model}, reasoning=${default_effort}. The default is STICKY: moving off it requires ENUMERATED POSITIVE EVIDENCE matching one of the tiers below. No evidence ⇒ stay on the default. A low-confidence verdict is discarded and replaced with the default downstream, so when in doubt emit confidence=low rather than guessing a tier.

Valid tiers (most→least effort):
${rows}

${constraints}

Output exactly this JSON shape (single line, no trailing newline):
{\"model\":\"${models}\",\"reasoning\":\"${efforts}\",\"confidence\":\"high|low\",\"rationale\":\"one short sentence\"}"
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
    _route_default_json "${kind}" "classifier-fallback"
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
    _route_default_json "${kind}" "classifier-fallback"
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

  if ! printf '%s' "${routing}" | jq -e 'has("model") and has("reasoning")' >/dev/null 2>&1; then
    warn "classifier: invalid output, using fallback"
    _route_debug "classifier: validation failed (${kind})" "${routing}"
    _route_default_json "${kind}" "classifier-fallback"
    return 0
  fi

  # Confidence gate: a low-confidence verdict resolves toward the per-kind
  # default rather than trusting a thin downgrade (or over-escalation).
  local confidence
  confidence="$(printf '%s' "${routing}" | jq -r '.confidence // "high"' 2>/dev/null)"
  if [ "${confidence}" = "low" ]; then
    warn "classifier: low confidence, using ${kind} default"
    _route_debug "classifier: low-confidence → default (${kind})" "${routing}"
    _route_default_json "${kind}" "low-confidence → default"
    return 0
  fi

  local model effort
  IFS=$'\t' read -r model effort < <(printf '%s' "${routing}" | jq -r '[.model, .reasoning] | @tsv' 2>/dev/null)
  if ! _route_has_pair "${kind}" "${model}" "${effort}"; then
    warn "classifier: ${model}+${effort} is not a ${kind} tier, using default"
    _route_debug "classifier: off-matrix pair → default (${kind})" "${routing}"
    _route_default_json "${kind}" "off-matrix → default"
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
    _route_default_json pr "classifier-fallback"
    return 0
  fi

  local payload
  payload="$(printf '%s' "${pr_json}" | jq -c '
    (.files // []) as $files |
    (.labels // []) as $labels |
    {
      title: (.title // ""),
      body: ((.body // "") | .[0:2000]),
      file_paths: [$files[].path],
      labels: [$labels[].name],
      branch: (.headRefName // "")
    }' 2>/dev/null)"

  if [ -z "${payload}" ]; then
    warn "classifier: could not build PR payload, using fallback"
    _route_default_json pr "classifier-fallback"
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
    _route_default_json story "classifier-fallback"
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
    _route_default_json story "classifier-fallback"
    return 0
  fi

  _classify story "${payload}"
}

#######################################
# Build the `claude` invocation string for launch_claude_in_pane, which makes
# it the claude pane's own process via tmux respawn-pane -k.
# Embeds a <routing-hint> block (plus an optional caller-provided extra
# block) via --append-system-prompt so the in-session model can see them.
# The system-prompt content survives Claude Code's plan-accept context
# clear, which is why operational guidance for post-plan-accept work
# belongs here rather than in a session skill.
# Arguments:
#   tier               — fable | opus | opusplan | sonnet | haiku
#   reasoning          — xhigh | high | medium | low
#   rationale          — one-line classifier reason
#   slash_command      — e.g. "/review-pr 123" or "/implement 12345"
#   extra_system_block — optional extra <…> block to append after the routing hint
#   extra_flags...     — optional, e.g. "--permission-mode" "plan"
# Outputs:
#   The full shell command string to stdout
#######################################
claude_launch_cmd() {
  local tier="${1}"
  local reasoning="${2}"
  local rationale="${3}"
  local slash_command="${4}"
  local extra_system_block="${5:-}"
  shift 5
  # ${1+...} for bash 3.2: the shift above can leave no positional
  # parameters, and "${@}" is then an unbound variable there, not an
  # empty list. A five-argument call is the case that reaches it.
  local -a extra_flags=(${1+"${@}"})

  local model
  model="$(model_id "${tier}")" || return 1

  local hint="<routing-hint>
model: ${tier}
reasoning: ${reasoning}
rationale: ${rationale}
</routing-hint>"

  if [ -n "${extra_system_block}" ]; then
    hint+=$'\n\n'"${extra_system_block}"
  fi

  # A multi-line prompt quoted into the command string has to survive tmux
  # argument parsing. Writing it to a file keeps it out of the command line.
  local system_prompt_arg
  if [ -n "${CLAUDE_PROMPT_FILE:-}" ]; then
    printf '%s' "${hint}" > "${CLAUDE_PROMPT_FILE}"
    system_prompt_arg="\"\$(cat $(printf '%q' "${CLAUDE_PROMPT_FILE}"))\""
  else
    system_prompt_arg="$(printf '%q' "${hint}")"
  fi

  # Quote the model arg: ID may contain [1m] which is a bash glob pattern.
  local cmd="claude --model $(printf '%q' "${model}") --effort ${reasoning}"
  local flag
  for flag in "${extra_flags[@]}"; do
    cmd+=" $(printf '%q' "${flag}")"
  done
  cmd+=" --append-system-prompt ${system_prompt_arg} -- $(printf '%q' "${slash_command}")"

  printf '%s' "${cmd}"
}

# When executed directly (not sourced), expose a tiny CLI. Currently just the
# matrix dumper, so docs/debugging can render the live table:
#   bash lib/route.sh print-matrix
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    print-matrix) route_print_matrix ;;
    *) error "usage: ${0##*/} print-matrix"; exit 1 ;;
  esac
fi
