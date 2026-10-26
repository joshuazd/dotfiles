#!/usr/bin/env bash
#
# lib/vigil.sh - Locate the vigil binary
#
# Usage:
#   source "${SCRIPT_DIR}/lib/vigil.sh"

[[ -n "${__LIB_VIGIL_LOADED:-}" ]] && return
readonly __LIB_VIGIL_LOADED=1

#######################################
# Print the path to the vigil binary.
#
# The menu bar app runs its scripts with a GUI PATH - homebrew plus the system
# directories - and tmux's run-shell inherits the server's environment, neither
# of which need include ~/.local/bin, where 'make install' puts vigil. A bare
# 'vigil' then exits 127 and the user sees only a generic failure, which says
# nothing about what to do.
#
# ${VIGIL_BIN:-} first, matching lib/tmux.sh's panel gate, so a dev build can
# be pointed at without editing this.
# Returns:
#   0 and the path on stdout, 1 if vigil cannot be found
#######################################
resolve_vigil() {
  if [ -n "${VIGIL_BIN:-}" ]; then
    printf '%s\n' "${VIGIL_BIN}"
    return 0
  fi
  local found
  if found="$(command -v vigil 2>/dev/null)" && [ -n "${found}" ]; then
    printf '%s\n' "${found}"
    return 0
  fi
  if [ -x "${HOME}/.local/bin/vigil" ]; then
    printf '%s\n' "${HOME}/.local/bin/vigil"
    return 0
  fi
  return 1
}
