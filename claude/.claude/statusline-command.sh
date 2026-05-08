#!/bin/sh
# Claude Code status line: colorful with model, dir, git, context, cost

# ANSI color codes — use printf to store real escape bytes, not literal \033
RESET=$(printf '\033[0m')
BOLD=$(printf '\033[1m')
DIM=$(printf '\033[2m')

# Colors matching the zsh prompt palette
BLUE=$(printf '\033[38;5;111m')      # %F{111} - light blue (directory color)
GOLD=$(printf '\033[38;5;222m')      # %F{222} - light gold (prompt char color)
GRAY=$(printf '\033[38;5;246m')      # mid-gray (git branch color)
GREEN=$(printf '\033[38;5;72m')      # green   - node / good cost
YELLOW=$(printf '\033[38;5;221m')    # yellow  - warning context
RED=$(printf '\033[38;5;196m')       # red     - high context / vim normal
CYAN=$(printf '\033[38;5;81m')       # cyan    - model name
PURPLE=$(printf '\033[38;5;141m')    # purple  - vim insert mode
ORANGE=$(printf '\033[38;5;208m')    # orange  - cost accent

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

# Dev server port (set by worktree Makefile.local at dev.server time)
# Only show if something is actually listening — otherwise the file is stale
dev_port=""
if [ -f "$cwd/tmp/dev.port" ]; then
  candidate=$(tr -d '[:space:]' < "$cwd/tmp/dev.port" 2>/dev/null)
  if [ -n "$candidate" ] && lsof -nP -iTCP:"$candidate" -sTCP:LISTEN -t >/dev/null 2>&1; then
    dev_port="$candidate"
  fi
fi


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

# Cost color: green below $0.50, orange $0.50-$1.99, red $2.00+
cost_num=$(echo "$cost" | tr -d '$')
if echo "$cost_num" | awk '{exit ($1 < 2.00)}'; then
  cost_color="$RED"
elif echo "$cost_num" | awk '{exit ($1 < 0.50)}'; then
  cost_color="$ORANGE"
else
  cost_color="$GREEN"
fi

# Vim mode indicator
vim_segment=""
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
if [ "$vim_mode" = "NORMAL" ]; then
  vim_segment="${RED} NORMAL ${RESET}  "
elif [ "$vim_mode" = "INSERT" ]; then
  vim_segment="${PURPLE} INSERT ${RESET}  "
fi

# Separator — use printf to emit actual escape bytes into the variable
SEP=$(printf '\033[0m\033[2m | \033[0m')

# Build status line

# Line 1: cwd + git branch
printf '%s%s%s' "${BLUE}" "${short_cwd}" "${RESET}"

if [ -n "$git_branch" ]; then
  printf ' %s⎇ %s%s' "${GRAY}" "${git_branch}" "${RESET}"
fi

if [ -n "$dev_port" ]; then
  printf ' %s:%s%s' "${GREEN}" "${dev_port}" "${RESET}"
fi

# Line 2: vim mode + model + version + context + cost
printf '\n'
printf '%s' "${vim_segment}"
NORM=$(tput sgr0)
printf '%s%s%s%s%s%s v%s\033[0m \033[2m|\033[0m ' "${CYAN}" "${BOLD}" "${model}" "${NORM}" "${CYAN}" "${DIM}" "${version}"

if [ -n "$ctx_segment" ]; then
  printf '%s' "${ctx_segment}"
  printf '%s' "${SEP}"
fi

printf '%s%s%s' "${cost_color}" "${cost}" "${RESET}"
