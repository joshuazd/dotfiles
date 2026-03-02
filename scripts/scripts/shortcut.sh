#!/bin/bash

# Shortcut API CLI tool
# Usage:
#   export SHORTCUT_API_TOKEN=your_token_here
#   ./scripts/shortcut.sh get-story <story-id>
#   ./scripts/shortcut.sh list-stories [--limit N]

set -e

API_BASE="https://api.app.shortcut.com/api/v3"

if [ -z "$SHORTCUT_API_TOKEN" ]; then
  echo "Error: SHORTCUT_API_TOKEN environment variable not set" >&2
  exit 1
fi

command="$1"

case "$command" in
  get-story)
    if [ -z "$2" ]; then
      echo "Error: story-id required" >&2
      echo "Usage: $0 get-story <story-id>" >&2
      exit 1
    fi
    story_id="$2"
    curl -s -X GET \
      -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
      -H "Content-Type: application/json" \
      "$API_BASE/stories/$story_id"
    ;;

  list-stories)
    # Team SOC Platform group ID
    GROUP_ID="60be5316-968b-4338-9bac-ef7ccdadfb0c"
    # Ready for Development state ID
    STATE_ID=500000007
    
    # Get recent iterations (started or unstarted)
    iteration_ids=$(curl -s -X GET \
      -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
      "$API_BASE/iterations" | jq -r '[.[] | select(.status == "started" or .status == "unstarted")] | .[0:5] | .[].id')
    
    # Collect stories from all recent iterations
    all_stories="[]"
    for iter_id in $iteration_ids; do
      stories=$(curl -s -X GET \
        -H "Shortcut-Token: $SHORTCUT_API_TOKEN" \
        "$API_BASE/iterations/$iter_id/stories")
      all_stories=$(echo "$all_stories$stories" | jq -s 'flatten | unique_by(.id)')
    done
    
    # Filter by group and state
    echo "$all_stories" | jq --arg gid "$GROUP_ID" --argjson sid "$STATE_ID" \
      '[.[] | select(.group_id == $gid and .workflow_state_id == $sid)]'
    ;;

  *)
    echo "Usage: $0 {get-story|list-stories} [args]" >&2
    echo "" >&2
    echo "Commands:" >&2
    echo "  get-story <story-id>      Get a single story by ID" >&2
    echo "  list-stories [--limit N]  List stories (default limit: 25)" >&2
    exit 1
    ;;
esac
