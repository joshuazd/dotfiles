#!/usr/bin/env bash
#
# lib/worktree.sh - What a worktree would cost to lose
#
# Removing a worktree is cheap when it is clean and pushed and expensive when
# it is not. These functions produce the two numbers that tell the difference,
# for the confirmation gate and for wt-pick's preview.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/worktree.sh"
#   worktree_risk_summary /path/to/worktree

[[ -n "${__LIB_WORKTREE_LOADED:-}" ]] && return
readonly __LIB_WORKTREE_LOADED=1

# Where a removal's output goes. Same convention as fzf-menu's @bg log.
# Read at call time rather than frozen here, so it is an overridable seam the
# way SCRIPTS_PKG_DIR and FZF_MENU_DIR are.
worktree_cleanup_log() {
  printf '%s' "${WORKTREE_CLEANUP_LOG:-${HOME}/.cache/worktree-cleanup.log}"
}

#######################################
# Run the cleanup script with its output sent to a log rather than at the user.
#
# Both callers run under `run-shell -b`, whose stdout tmux writes into the
# focused pane - and after `prefix d` that is a pane in some OTHER session the
# user just landed in, which has nothing to do with the worktree that went
# away. A popup was the previous answer and was worse: a box to dismiss after
# every removal.
#
# So: nowhere on screen, but not /dev/null either. A cleanup that refuses -
# a dirty worktree, a directory already gone - has to leave a trace somewhere
# findable, and this is it.
# Arguments:
#   Path to the cleanup script, then its own arguments
# Returns:
#   The cleanup's status
#######################################
worktree_run_cleanup() {
  local script="${1}"
  shift

  local log
  log="$(worktree_cleanup_log)"
  mkdir -p "$(dirname "${log}")" 2>/dev/null || true
  {
    printf '=== %s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${*}"
    "${script}" ${1+"${@}"}
  } >> "${log}" 2>&1
}

#######################################
# Count uncommitted changes, staged or not, tracked or not.
#
# A directory that is not a git repository counts as clean rather than
# erroring: the caller is about to describe a removal, and a hard failure
# there would replace a useful prompt with a stack of git noise.
# Arguments:
#   Worktree directory
# Outputs:
#   The count to stdout
#######################################
worktree_dirty_count() {
  local dir="${1}"
  git -C "${dir}" status --porcelain 2>/dev/null | grep -c . || true
}

#######################################
# Count commits present locally and absent upstream.
# Arguments:
#   Worktree directory
# Outputs:
#   The count to stdout, or nothing at all when the branch has no upstream
#   (which is not an error - a branch that was never pushed has no answer to
#   this question)
#######################################
worktree_unpushed_count() {
  local dir="${1}"
  git -C "${dir}" rev-list --count '@{upstream}..HEAD' 2>/dev/null || true
}

#######################################
# The branch a worktree has checked out.
#
# A detached HEAD has no branch name and reports the short sha instead, which
# is still the answer to "what am I about to lose". Nothing at all when the
# directory is not a git repository, so the caller can drop the line rather
# than show an empty one.
# Arguments:
#   Worktree directory
# Outputs:
#   The branch name or short sha to stdout, or nothing
#######################################
worktree_branch() {
  local dir="${1}"
  local name
  name="$(git -C "${dir}" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  if [ -z "${name}" ]; then
    name="$(git -C "${dir}" rev-parse --short HEAD 2>/dev/null || true)"
  fi
  printf '%s' "${name}"
}

#######################################
# One line naming everything at risk in a worktree.
# Arguments:
#   Worktree directory
# Outputs:
#   e.g. "3 uncommitted files, 2 unpushed commits", or "clean"
#######################################
worktree_risk_summary() {
  local dir="${1}"
  local dirty unpushed
  dirty="$(worktree_dirty_count "${dir}")"
  unpushed="$(worktree_unpushed_count "${dir}")"

  local -a parts=()
  if [ "${dirty}" -gt 0 ]; then
    if [ "${dirty}" -eq 1 ]; then
      parts+=("1 uncommitted file")
    else
      parts+=("${dirty} uncommitted files")
    fi
  fi
  if [ -n "${unpushed}" ] && [ "${unpushed}" -gt 0 ]; then
    if [ "${unpushed}" -eq 1 ]; then
      parts+=("1 unpushed commit")
    else
      parts+=("${unpushed} unpushed commits")
    fi
  fi

  # bash 3.2 treats an empty array as unbound under `set -o nounset`, so the
  # count has to be read before "${parts[@]}" is ever expanded.
  if [ "${#parts[@]}" -eq 0 ]; then
    printf 'clean'
    return 0
  fi

  local IFS=', '
  printf '%s' "${parts[*]}"
}
