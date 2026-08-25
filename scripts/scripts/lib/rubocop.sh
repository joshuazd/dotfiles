#!/usr/bin/env bash
#
# lib/rubocop.sh - RuboCop server lifecycle for worktrees
#
# `rubocop --server` starts one long-lived server per project root and nothing
# ever stops it, so a removed worktree leaks its server and its state directory
# forever.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/rubocop.sh"

[[ -n "${__LIB_RUBOCOP_LOADED:-}" ]] && return
readonly __LIB_RUBOCOP_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"

#######################################
# Print the directory holding every rubocop server's state.
# Outputs:
#   Writes the server root path to stdout
#######################################
rubocop_server_root() {
  local cache_root="${RUBOCOP_CACHE_ROOT:-${XDG_CACHE_HOME:-${HOME}/.cache}/rubocop_cache}"

  printf "%s" "${cache_root}/server"
}

#######################################
# Print the state directory rubocop uses for a project root.
#
# RuboCop flattens the absolute project path into a single directory name by
# dropping the leading slash and replacing every remaining one with '+', so
# /Users/me/sc-1 becomes Users+me+sc-1.
# Arguments:
#   Absolute project root path
# Outputs:
#   Writes the server state directory path to stdout
#######################################
rubocop_server_dir() {
  local project_path="${1}"
  local mangled="${project_path#/}"
  mangled="${mangled//\//+}"

  printf "%s" "$(rubocop_server_root)/${mangled}"
}

#######################################
# Print the project root a server state directory name came from.
# Arguments:
#   State directory name (not a path)
# Outputs:
#   Writes the absolute project root path to stdout
#######################################
rubocop_project_path() {
  local mangled="${1}"

  printf "/%s" "${mangled//+//}"
}

#######################################
# Print the PID recorded in a server state directory.
# Arguments:
#   Server state directory path
# Outputs:
#   Writes the PID to stdout
# Returns:
#   0 when a numeric PID was read, 1 when the file is missing or unusable
#######################################
rubocop_server_pid() {
  local server_dir="${1}"
  local pid

  [ -f "${server_dir}/pid" ] || return 1
  pid="$(tr -d '[:space:]' < "${server_dir}/pid")"
  [[ "${pid}" =~ ^[0-9]+$ ]] || return 1

  printf "%s" "${pid}"
}

#######################################
# Report whether a PID belongs to a rubocop process.
#
# pid files outlive their servers by weeks, by which point the operating system
# has recycled the number onto something unrelated. Every signal this library
# sends is gated on this check, so a stale pid file costs a skipped kill rather
# than someone else's process.
# Arguments:
#   PID
# Returns:
#   0 if the PID is a live rubocop process, 1 otherwise
#######################################
is_rubocop_process() {
  local pid="${1}"
  local process_command

  process_command="$(ps -p "${pid}" -o command= 2>/dev/null)" || return 1

  case "${process_command}" in
    *rubocop*) return 0 ;;
    *) return 1 ;;
  esac
}

#######################################
# Stop the rubocop server for a worktree and drop its state directory.
# Arguments:
#   Absolute worktree path
# Returns:
#   0 always: an absent server, a stale pid file and a dead process are all
#   ordinary outcomes of cleaning up a worktree
#######################################
stop_rubocop_server() {
  local worktree_path="${1}"
  local server_dir
  local pid

  server_dir="$(rubocop_server_dir "${worktree_path}")"
  [ -d "${server_dir}" ] || return 0

  if pid="$(rubocop_server_pid "${server_dir}")"; then
    if is_rubocop_process "${pid}"; then
      info "Stopping rubocop server ${pid} for ${worktree_path}"
      kill -TERM "${pid}" 2>/dev/null || warn "Failed to signal rubocop server ${pid}"
    else
      info "Rubocop pid ${pid} is not a rubocop process, leaving it alone"
    fi
  fi

  \rm -rf "${server_dir}"
  return 0
}

#######################################
# Remove server state directories whose server is dead or whose project is gone.
#
# A live server whose project directory still exists is left running: it is the
# only case where the server is still doing its job.
# Arguments:
#   "--dry-run" to report without changing anything (optional)
# Outputs:
#   Writes one line per pruned server, plus a summary
# Returns:
#   0 always
#######################################
prune_rubocop_servers() {
  local dry_run="${1:-}"
  local server_root
  local server_dir
  local project_path
  local pid
  local pruned=0

  server_root="$(rubocop_server_root)"
  [ -d "${server_root}" ] || {
    info "No rubocop server state at ${server_root}"
    return 0
  }

  for server_dir in "${server_root}"/*; do
    [ -d "${server_dir}" ] || continue

    project_path="$(rubocop_project_path "${server_dir##*/}")"
    pid="$(rubocop_server_pid "${server_dir}")" || pid=""

    if [ -n "${pid}" ] && is_rubocop_process "${pid}" && [ -d "${project_path}" ]; then
      continue
    fi

    if [ "${dry_run}" = "--dry-run" ]; then
      info "Would prune ${project_path} (pid ${pid:-none})"
    else
      stop_rubocop_server "${project_path}"
      \rm -rf "${server_dir}"
      info "Pruned ${project_path} (pid ${pid:-none})"
    fi
    ((pruned++)) || true
  done

  if [ "${dry_run}" = "--dry-run" ]; then
    info "${pruned} rubocop server state directories would be pruned"
  else
    info "Pruned ${pruned} rubocop server state directories"
  fi

  return 0
}
