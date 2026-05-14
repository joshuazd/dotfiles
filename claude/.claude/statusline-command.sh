#!/bin/bash
# Claude Code status line: colorful with model, dir, git, context, cost

RESET=$(printf '\033[0m')
BOLD=$(printf '\033[1m')
DIM=$(printf '\033[2m')

# Palette matching the zsh prompt
BLUE=$(printf '\033[38;5;111m')      # directory
GRAY=$(printf '\033[38;5;246m')      # git branch
GREEN=$(printf '\033[38;5;72m')      # low/good
YELLOW=$(printf '\033[38;5;221m')    # warning
RED=$(printf '\033[38;5;196m')       # alert
CYAN=$(printf '\033[38;5;81m')       # model
PURPLE=$(printf '\033[38;5;141m')    # vim insert
ORANGE=$(printf '\033[38;5;208m')    # cost mid

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  printf '%sjq required for statusline%s\n' "$RED" "$RESET"
  exit 0
fi

# Single jq call → tab-separated fields → read into shell vars
IFS=$'\t' read -r model cwd version cost_usd used_pct vim_mode < <(
  printf '%s' "$input" | jq -r '[
    .model.display_name // "Unknown Model",
    .cwd // .workspace.current_dir // "unknown",
    .version // "unknown",
    .cost.total_cost_usd // 0,
    .context_window.used_percentage // "",
    .vim.mode // ""
  ] | @tsv'
)

# $HOME → ~ via pure shell (avoids sed delimiter issues if HOME has odd chars)
case "$cwd" in
  "$HOME")   short_cwd="~" ;;
  "$HOME"/*) short_cwd="~${cwd#"$HOME"}" ;;
  *)         short_cwd="$cwd" ;;
esac

# If path has more than 2 segments below ~ or /, collapse to "<prefix>/…/parent/leaf"
short_cwd=$(printf '%s' "$short_cwd" | awk -F/ '
{
  has_root = ($1 == "")
  has_home = ($1 == "~")
  n = NF - (has_root || has_home ? 1 : 0)
  if (n <= 2) { print $0; next }
  if      (has_home) prefix = "~/…/"
  else if (has_root) prefix = "/…/"
  else               prefix = "…/"
  print prefix $(NF-1) "/" $NF
}')

# Git branch (skip optional lock to avoid blocking)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Dev server port (set by worktree Makefile.local at dev.server time);
# only show if something is actually listening — otherwise the file is stale
dev_port=""
if [ -f "$cwd/tmp/dev.port" ]; then
  candidate=$(tr -d '[:space:]' < "$cwd/tmp/dev.port" 2>/dev/null)
  if [ -n "$candidate" ] && lsof -nP -iTCP:"$candidate" -sTCP:LISTEN -t >/dev/null 2>&1; then
    dev_port=$candidate
  fi
fi

# Float >= compare helper. Returns 0 (true) iff a >= b.
ge() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a >= b) }'; }

# Context bar + color
ctx_segment=""
if [ -n "$used_pct" ]; then
  bar=$(awk -v p="$used_pct" 'BEGIN {
    filled = int(p / 10 + 0.5)
    for (i = 1; i <= 10; i++) printf (i <= filled ? "█" : "░")
  }')

  if   ge "$used_pct" 70; then ctx_color=$RED
  elif ge "$used_pct" 40; then ctx_color=$YELLOW
  else                         ctx_color=$GREEN
  fi

  used_pct_fmt=$(printf '%.0f' "$used_pct")
  ctx_segment="${DIM}ctx:${RESET}${ctx_color}${bar} ${used_pct_fmt}%${RESET}"
fi

# Cost: Claude Code provides this pre-computed (handles caching, 1M ctx, model rates)
cost=$(printf '$%.2f' "$cost_usd")
if   ge "$cost_usd" 10.00; then cost_color=$RED
elif ge "$cost_usd"  2.00; then cost_color=$ORANGE
else                            cost_color=$GREEN
fi

# Vim mode indicator
vim_segment=""
case "$vim_mode" in
  NORMAL)               vim_segment="${RED} NORMAL ${RESET}  " ;;
  INSERT)               vim_segment="${PURPLE} INSERT ${RESET}  " ;;
  VISUAL|"VISUAL LINE") vim_segment="${YELLOW} ${vim_mode} ${RESET}  " ;;
esac

SEP="${DIM} | ${RESET}"

# Line 1: cwd + git branch + dev port
printf '%s%s%s' "$BLUE" "$short_cwd" "$RESET"
[ -n "$git_branch" ] && printf ' %s⎇ %s%s' "$GRAY" "$git_branch" "$RESET"
[ -n "$dev_port" ]   && printf ' %s:%s%s' "$GREEN" "$dev_port" "$RESET"

# Line 2: vim mode + model + version + context + cost
printf '\n%s' "$vim_segment"
printf '%s%s%s%s%s%s v%s%s%s' \
  "$CYAN" "$BOLD" "$model" "$RESET" "$CYAN" "$DIM" "$version" "$RESET" "$SEP"
[ -n "$ctx_segment" ] && printf '%s%s' "$ctx_segment" "$SEP"
printf '%s%s%s' "$cost_color" "$cost" "$RESET"
