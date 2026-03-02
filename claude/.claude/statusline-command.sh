#!/bin/sh
# Claude Code status line: colorful with model, dir, git, context, cost

# ANSI color codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Colors matching the zsh prompt palette
BLUE='\033[38;5;111m'      # %F{111} - light blue (directory color)
GOLD='\033[38;5;222m'      # %F{222} - light gold (prompt char color)
GRAY='\033[38;5;8m'        # %F{8}   - dark gray (git branch color)
GREEN='\033[38;5;72m'      # green   - node / good cost
YELLOW='\033[38;5;221m'    # yellow  - warning context
RED='\033[38;5;196m'       # red     - high context / vim normal
CYAN='\033[38;5;81m'       # cyan    - model name
PURPLE='\033[38;5;141m'    # purple  - vim insert mode
ORANGE='\033[38;5;208m'    # orange  - cost accent

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
model_id=$(echo "$input" | jq -r '.model.id // ""')
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // "unknown"')
version=$(echo "$input" | jq -r '.version // "unknown"')

# Shorten home directory to ~ then keep only last 2 path components
home="$HOME"
full_cwd=$(echo "$cwd" | sed "s|^$home|~|")
short_cwd=$(echo "$full_cwd" | awk -F/ '{
  if (NF <= 2) print $0
  else print $(NF-1) "/" $NF
}')

# Git branch (skip optional lock to avoid blocking)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Hide branch when the last dir component ends with the last branch component (redundant in worktree flow)
# Covers exact match (dir "my-feature", branch "feature/my-feature") and
# prefixed dir (dir "pr-sc-188342-foo", branch "feature/sc-188342-foo")
last_dir_component=$(basename "$cwd")
last_branch_component=$(echo "$git_branch" | awk -F/ '{print $NF}')
case "$last_dir_component" in
  *"$last_branch_component") git_branch="" ;;
esac

# Token pricing per million tokens
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

case "$model_id" in
  *claude-opus-4*|*claude-opus-4-5*)
    input_price="15"; output_price="75" ;;
  *claude-sonnet-4*|*claude-sonnet-4-5*)
    input_price="3"; output_price="15" ;;
  *claude-haiku-3-5*|*claude-haiku-3.5*)
    input_price="0.8"; output_price="4" ;;
  *claude-haiku*)
    input_price="0.25"; output_price="1.25" ;;
  *claude-opus*)
    input_price="15"; output_price="75" ;;
  *claude-sonnet*)
    input_price="3"; output_price="15" ;;
  *)
    input_price="3"; output_price="15" ;;
esac

cost=$(echo "$total_input $input_price $total_output $output_price" | awk '{
  cost = ($1 / 1000000 * $2) + ($3 / 1000000 * $4)
  printf "$%.2f", cost
}')

# Context usage percentage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Context bar and color
ctx_segment=""
if [ -n "$used_pct" ]; then
  # Build a small bar: 10 chars wide
  bar=$(echo "$used_pct" | awk '{
    filled = int($1 / 10 + 0.5)
    bar = ""
    for (i = 1; i <= 10; i++) {
      if (i <= filled) bar = bar "█"
      else bar = bar "░"
    }
    printf "%s", bar
  }')

  # Color the bar based on usage
  if echo "$used_pct" | awk '{exit ($1 < 70)}'; then
    ctx_color="$RED"
  elif echo "$used_pct" | awk '{exit ($1 < 40)}'; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi

  used_pct_fmt=$(printf "%.0f" "$used_pct")
  ctx_segment="${DIM}ctx:${RESET}${ctx_color}${bar} ${used_pct_fmt}%${RESET}"
fi

# Cost color: green below $0.25, orange $0.25-$0.99, red $1.00+
cost_num=$(echo "$cost" | tr -d '$')
if echo "$cost_num" | awk '{exit ($1 < 1.00)}'; then
  cost_color="$RED"
elif echo "$cost_num" | awk '{exit ($1 < 0.25)}'; then
  cost_color="$ORANGE"
else
  cost_color="$GREEN"
fi

# Vim mode indicator
vim_segment=""
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
if [ "$vim_mode" = "NORMAL" ]; then
  vim_segment="${RED}${BOLD} NORMAL ${RESET}  "
elif [ "$vim_mode" = "INSERT" ]; then
  vim_segment="${PURPLE}${BOLD} INSERT ${RESET}  "
fi

# Separator
SEP="${DIM} | ${RESET}"

# Build status line
printf "${vim_segment}"
printf "${CYAN}${BOLD}${model}${RESET}"
printf "${DIM} v${version}${RESET}"
printf "${SEP}"
printf "${BLUE}${short_cwd}${RESET}"

if [ -n "$git_branch" ]; then
  printf "${GRAY} [${git_branch}]${RESET}"
fi

printf "${SEP}"

if [ -n "$ctx_segment" ]; then
  printf "${ctx_segment}"
  printf "${SEP}"
fi

printf "${cost_color}${BOLD}${cost}${RESET}"
