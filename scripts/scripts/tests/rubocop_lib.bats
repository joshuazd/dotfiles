#!/usr/bin/env bats

load helper

setup() {
  source "${BATS_TEST_DIRNAME}/../lib/rubocop.sh"
  export HOME="${BATS_TEST_TMPDIR}/home"
  export RUBOCOP_CACHE_ROOT="${BATS_TEST_TMPDIR}/rubocop_cache"
  mkdir -p "${HOME}"
  STARTED_PIDS=()
}

teardown() {
  local pid
  for pid in ${STARTED_PIDS[@]+"${STARTED_PIDS[@]}"}; do
    kill -KILL "${pid}" 2> /dev/null || true
  done
}

# Sets SLEEPER_PID rather than printing it: a command substitution would run
# the whole thing in a subshell, and teardown would never learn the pid.
#
# Background processes must not inherit bats' fd 3, or the run never finishes,
# and disown keeps the shell from printing a "Killed" job notice when teardown
# reaps whatever is left.
start_sleeper() {
  sleep 30 > /dev/null 2>&1 3>&- &
  SLEEPER_PID="${!}"
  STARTED_PIDS+=("${SLEEPER_PID}")
  disown "${SLEEPER_PID}" 2> /dev/null || true
}

# A process whose command line reads as rubocop, without needing rubocop
# installed: the safety check reads `ps -o command=`, and `exec -a` is what
# puts the name there.
start_fake_rubocop() {
  bash -c 'exec -a rubocop sleep 30' > /dev/null 2>&1 3>&- &
  SLEEPER_PID="${!}"
  STARTED_PIDS+=("${SLEEPER_PID}")
  disown "${SLEEPER_PID}" 2> /dev/null || true
}

seed_server_dir() {
  local project_path="${1}"
  local pid="${2}"
  local server_dir

  server_dir="$(rubocop_server_dir "${project_path}")"
  mkdir -p "${server_dir}"
  printf '%s\n' "${pid}" > "${server_dir}/pid"
  printf "%s" "${server_dir}"
}

process_alive() {
  kill -0 "${1}" 2> /dev/null
}

await_exit() {
  local pid="${1}"
  local attempt=0

  while [ "${attempt}" -lt 40 ]; do
    process_alive "${pid}" || return 0
    attempt=$((attempt + 1))
    sleep 0.1
  done
  return 1
}

@test "rubocop_server_dir replaces path separators with plus signs" {
  run rubocop_server_dir "/Users/joshua.zink-duda/sc-198799"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${RUBOCOP_CACHE_ROOT}/server/Users+joshua.zink-duda+sc-198799" ]
}

@test "rubocop_server_dir falls back to the XDG cache when unset" {
  unset RUBOCOP_CACHE_ROOT
  export XDG_CACHE_HOME="${BATS_TEST_TMPDIR}/xdg"

  run rubocop_server_dir "/tmp/proj"
  [ "${status}" -eq 0 ]
  [ "${output}" = "${BATS_TEST_TMPDIR}/xdg/rubocop_cache/server/tmp+proj" ]
}

@test "rubocop_project_path reverses the mangling" {
  run rubocop_project_path "Users+me+sc-1"
  [ "${status}" -eq 0 ]
  [ "${output}" = "/Users/me/sc-1" ]
}

# The whole safety requirement: a pid file weeks old can name a PID the system
# has since handed to something else, and that something else must survive.
@test "stop_rubocop_server does not signal a pid that is not rubocop" {
  start_sleeper
  local pid="${SLEEPER_PID}"
  local server_dir
  server_dir="$(seed_server_dir "/tmp/gone-worktree" "${pid}")"

  run stop_rubocop_server "/tmp/gone-worktree"
  [ "${status}" -eq 0 ]
  process_alive "${pid}"
  [ ! -d "${server_dir}" ]
}

@test "stop_rubocop_server terminates a live rubocop server" {
  start_fake_rubocop
  local pid="${SLEEPER_PID}"
  local server_dir
  server_dir="$(seed_server_dir "/tmp/live-worktree" "${pid}")"

  run stop_rubocop_server "/tmp/live-worktree"
  [ "${status}" -eq 0 ]
  await_exit "${pid}"
  [ ! -d "${server_dir}" ]
}

@test "stop_rubocop_server is a no-op when no state directory exists" {
  run stop_rubocop_server "/tmp/never-existed"
  [ "${status}" -eq 0 ]
}

@test "stop_rubocop_server drops a state directory with a garbage pid file" {
  local server_dir
  server_dir="$(seed_server_dir "/tmp/garbage" "not-a-pid")"

  run stop_rubocop_server "/tmp/garbage"
  [ "${status}" -eq 0 ]
  [ ! -d "${server_dir}" ]
}

@test "stop_rubocop_server drops a state directory with no pid file" {
  local server_dir
  server_dir="$(rubocop_server_dir "/tmp/no-pid")"
  mkdir -p "${server_dir}"

  run stop_rubocop_server "/tmp/no-pid"
  [ "${status}" -eq 0 ]
  [ ! -d "${server_dir}" ]
}

@test "prune_rubocop_servers removes state for a dead server" {
  local server_dir
  server_dir="$(seed_server_dir "/tmp/dead-project" "999999")"

  run prune_rubocop_servers
  [ "${status}" -eq 0 ]
  [ ! -d "${server_dir}" ]
}

@test "prune_rubocop_servers keeps a live server whose project still exists" {
  local project="${BATS_TEST_TMPDIR}/live-project"
  mkdir -p "${project}"
  start_fake_rubocop
  local pid="${SLEEPER_PID}"
  local server_dir
  server_dir="$(seed_server_dir "${project}" "${pid}")"

  run prune_rubocop_servers
  [ "${status}" -eq 0 ]
  [ -d "${server_dir}" ]
  process_alive "${pid}"
}

@test "prune_rubocop_servers --dry-run changes nothing" {
  local server_dir
  server_dir="$(seed_server_dir "/tmp/dead-project" "999999")"

  run prune_rubocop_servers --dry-run
  [ "${status}" -eq 0 ]
  [ -d "${server_dir}" ]
  [[ "${output}" == *"Would prune /tmp/dead-project"* ]]
}
