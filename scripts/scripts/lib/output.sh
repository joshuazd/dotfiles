#!/usr/bin/env bash
#
# lib/output.sh - Colored output helpers and argument utilities
#
# Usage:
#   source "${SCRIPT_DIR}/lib/output.sh"

[[ -n "${__LIB_OUTPUT_LOADED:-}" ]] && return
readonly __LIB_OUTPUT_LOADED=1

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

#######################################
# Print error message to stderr
# Arguments:
#   Error message
# Outputs:
#   Writes error message to stderr
#######################################
error() {
  printf "${RED}!!! %s${RESET}\\n" "${*}" 1>&2
}

#######################################
# Print info message to stdout
# Arguments:
#   Info message
# Outputs:
#   Writes info message to stdout
#######################################
info() {
  printf "${GREEN}>>> %s${RESET}\\n" "${*}"
}

#######################################
# Print warning message to stdout
# Arguments:
#   Warning message
# Outputs:
#   Writes warning message to stdout
#######################################
warn() {
  printf "${YELLOW}!!! %s${RESET}\\n" "${*}"
}

#######################################
# Check if help is requested
# Arguments:
#   All script arguments
# Returns:
#   0 if help is wanted, 1 otherwise
#######################################
help_wanted() {
  [ "${#}" -ge 1 ] && { [ "${1}" = '-h' ] || [ "${1}" = '--help' ] || [ "${1}" = '-?' ]; }
}
