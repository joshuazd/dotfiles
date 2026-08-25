#!/usr/bin/env bash
# PreToolUse hook: in a read-only-remote session (CLAUDE_READONLY_REMOTE=1),
# deny anything that writes to a remote - git push, remote-mutating gh calls,
# Shortcut updates, Slack posts.
#
# These sessions run with permissions bypassed so a PR review never stops to
# ask, which makes this hook the only thing between the model and a push or a
# posted comment. It is therefore an allowlist, not a blocklist: an unknown
# gh/short subcommand is denied, not permitted.
#
# Unset CLAUDE_READONLY_REMOTE and the hook is a no-op, so ordinary sessions
# are unaffected.

set -euo pipefail

[ "${CLAUDE_READONLY_REMOTE:-}" = "1" ] || exit 0

payload="$(cat)"
tool="$(printf '%s' "${payload}" | jq -r '.tool_name // ""')"

deny() {
  jq -n --arg r "${1}" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": ("BLOCKED (read-only-remote session): " + $r + " Report it in conversation instead; the user takes the remote-visible action.")
    }
  }'
  exit 0
}

# MCP tools: only the read-shaped verbs survive. Everything else - send,
# post, schedule, create, update - reaches a remote by definition.
if [ "${tool#mcp__}" != "${tool}" ]; then
  case "${tool}" in
    *_read_*|*_search_*|*_list_*|*_get_*|*_analyze_*) exit 0 ;;
    *) deny "${tool} writes to a remote service." ;;
  esac
fi

[ "${tool}" = "Bash" ] || exit 0

command="$(printf '%s' "${payload}" | jq -r '.tool_input.command // ""')"
[ -z "${command}" ] && exit 0

# Check every segment of the command line, not just the first: a push hidden
# behind `&&`, a pipe, or a `$(...)` runs just the same. Splitting on these
# characters also splits inside quotes, which can only ever produce a spurious
# extra segment - erring toward a deny, which is the safe direction.
segments="$(printf '%s' "${command}" | tr ';|&()`\n' '\n')"

# Args to `git` proper, with the global flags and their values dropped, so the
# subcommand is $1 for `git -C /path push` as much as for `git push`.
git_subcommand_args() {
  local -a out=()
  while [ "${#}" -gt 0 ]; do
    case "${1}" in
      -C|-c|--git-dir|--work-tree|--namespace|--exec-path) shift 2 2>/dev/null || break ;;
      -*) shift ;;
      *) out+=("${@}"); break ;;
    esac
  done
  printf '%s\n' ${out[@]+"${out[@]}"}
}

check_git() {
  local -a args
  # shellcheck disable=SC2207 # the args are already word-split by the caller
  args=($(git_subcommand_args "${@}"))
  case "${args[0]:-}" in
    push)
      deny "\`git push\` publishes commits."
      ;;
    remote)
      case "${args[1]:-}" in
        add|set-url|set-head|set-branches|rename|remove|rm)
          deny "\`git remote ${args[1]}\` rewrites where this worktree publishes to."
          ;;
      esac
      ;;
    send-email|request-pull|svn|p4)
      deny "\`git ${args[0]}\` reaches a remote."
      ;;
  esac
}

# `gh api` is read-only only when it neither names a write method nor carries a
# request body. `gh api graphql -f query=...` is the exception the review flow
# depends on: a POST that only reads, so it passes unless it runs a mutation.
check_gh_api() {
  local rest="${*}"
  if printf '%s' "${rest}" | grep -qE '(-X|--method)[[:space:]]+(POST|PUT|PATCH|DELETE|post|put|patch|delete)'; then
    deny "\`gh api\` with a write method mutates GitHub."
  fi
  if printf '%s' "${rest}" | grep -qw graphql; then
    if printf '%s' "${rest}" | grep -qiw mutation; then
      deny "\`gh api graphql\` running a mutation writes to GitHub."
    fi
    return 0
  fi
  if printf '%s' "${rest}" | grep -qE '(^|[[:space:]])(-f|-F|--field|--raw-field|--input)([[:space:]]|=)'; then
    deny "\`gh api\` with a request body POSTs to GitHub."
  fi
}

check_gh() {
  shift # gh
  local sub="${1:-}" verb="${2:-}"
  case "${sub}" in
    pr)
      case "${verb}" in view|diff|list|status|checks) return 0 ;; esac
      ;;
    issue)
      case "${verb}" in view|list|status) return 0 ;; esac
      ;;
    run)
      case "${verb}" in view|list|watch|download) return 0 ;; esac
      ;;
    repo)
      case "${verb}" in view|list|clone) return 0 ;; esac
      ;;
    release)
      case "${verb}" in view|list|download) return 0 ;; esac
      ;;
    workflow)
      case "${verb}" in view|list) return 0 ;; esac
      ;;
    label|cache|ruleset|variable|secret)
      case "${verb}" in list|view) return 0 ;; esac
      ;;
    auth)
      case "${verb}" in status) return 0 ;; esac
      ;;
    search|browse|status|version|help)
      return 0
      ;;
    api)
      shift
      check_gh_api "${@}"
      return 0
      ;;
  esac
  deny "\`gh ${sub} ${verb}\` is not on the read-only allowlist."
}

readonly SHORT_STORY_WRITE_FLAGS='-a|--archived|-c|--comment|-d|--description|-e|--estimate|--epic|-i|--iteration|--move-after|--move-before|--move-down|--move-up|-o|--owners|-s|--state|-t|--title|-T|--team|--task|--task-complete'

check_short() {
  shift # short
  local sub="${1:-}"
  case "${sub}" in
    story|st)
      shift
      local arg
      for arg in ${1+"${@}"}; do
        if printf '%s' "${arg}" | grep -qE "^(${SHORT_STORY_WRITE_FLAGS})(=|$)"; then
          deny "\`short story ${arg}\` updates the Shortcut story."
        fi
      done
      ;;
    search|s|find|members|m|workflows|wf|epics|e|iterations|i|docs|d|projects|p|workspace|w|help)
      return 0
      ;;
    *)
      deny "\`short ${sub}\` is not on the read-only allowlist."
      ;;
  esac
}

check_http() {
  local rest="${*}"
  if printf '%s' "${rest}" | grep -qE '(^|[[:space:]])(-X|--request)[[:space:]]+(POST|PUT|PATCH|DELETE|post|put|patch|delete)'; then
    deny "an HTTP write to an external service."
  fi
  if printf '%s' "${rest}" | grep -qE '(^|[[:space:]])(-d|--data|--data-raw|--data-binary|--data-urlencode|--post-data|-F|--form)([[:space:]]|=)'; then
    deny "an HTTP request with a body to an external service."
  fi
}

while IFS= read -r segment; do
  # shellcheck disable=SC2206 # deliberate word splitting: this is a command line
  words=(${segment})
  # Skip leading `env`-style assignments and `sudo`/`command`/`xargs` wrappers
  # so `FOO=1 git push` is still seen as a push.
  while [ "${#words[@]}" -gt 0 ]; do
    case "${words[0]}" in
      *=*|sudo|command|env|nohup|time|xargs) words=("${words[@]:1}") ;;
      *) break ;;
    esac
  done
  [ "${#words[@]}" -eq 0 ] && continue

  case "${words[0]##*/}" in
    git) check_git "${words[@]:1}" ;;
    gh) check_gh "${words[@]}" ;;
    short) check_short "${words[@]}" ;;
    curl|wget) check_http "${words[@]:1}" ;;
  esac
done <<< "${segments}"

exit 0
