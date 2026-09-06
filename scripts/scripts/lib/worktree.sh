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
