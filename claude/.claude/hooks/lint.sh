#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

input="$(cat)"
file_path="$(echo "${input}" | jq -r '.tool_input.file_path')"
cwd="$(echo "${input}" | jq -r '.cwd')"

run_rubocop() {
  local config_args=()
  # View files use a separate rubocop config if it exists
  case "${file_path}" in
    *.html.haml|*.html.erb)
      if [ -f "${cwd}/.rubocop_views.yml" ]; then
        config_args=(--config "${cwd}/.rubocop_views.yml")
      fi
      ;;
  esac

  local output exit_code=0
  output="$(cd "${cwd}" && bundle exec rubocop --autocorrect --force-exclusion "${config_args[@]}" "${file_path}" 2>&1)" || exit_code=$?
  if [ "${exit_code}" -ne 0 ]; then
    echo "${output}" >&2
    exit 2
  fi
}

run_eslint() {
  local output exit_code=0
  output="$(cd "${cwd}" && yarn run eslint --fix "${file_path}" 2>&1)" || exit_code=$?
  if [ "${exit_code}" -ne 0 ]; then
    echo "${output}" >&2
    exit 2
  fi
}

case "${file_path}" in
  *.rb|*.rake|*.html.haml|*.html.erb)
    if [ -f "${cwd}/Gemfile" ]; then
      run_rubocop
    fi
    ;;
  *.js)
    if [ -f "${cwd}/.eslintrc.json" ] || [ -f "${cwd}/.eslintrc.js" ]; then
      run_eslint
    fi
    ;;
esac

exit 0
