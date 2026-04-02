#!/usr/bin/env bash
#
# common.sh - Sources all library files for backward compatibility
#
# Individual libraries can be sourced directly from lib/ when only a
# subset of functionality is needed:
#   source "${SCRIPT_DIR}/lib/output.sh"   — colors, error/info/warn, help_wanted
#   source "${SCRIPT_DIR}/lib/git.sh"      — is_git_repo, get_name_from_branch, extract_story_id, normalize_pr_input
#   source "${SCRIPT_DIR}/lib/shortcut.sh" — fetch_story_json, title_from_json, branch_from_json
#   source "${SCRIPT_DIR}/lib/tmux.sh"     — tmux session mgmt, worktree popup, resolve_session_name
#
# Usage:
#   source "${SCRIPT_DIR}/common.sh"

readonly _COMMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"

source "${_COMMON_LIB_DIR}/output.sh"
source "${_COMMON_LIB_DIR}/git.sh"
source "${_COMMON_LIB_DIR}/shortcut.sh"
source "${_COMMON_LIB_DIR}/tmux.sh"
