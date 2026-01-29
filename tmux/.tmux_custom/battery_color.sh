#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
percentage=$("$CURRENT_DIR/battery_percentage.sh" | sed 's/%//')

if [ "$percentage" -eq 100 ]; then
    printf '#[fg=colour70]'
elif [ "$percentage" -ge 60 ]; then
    printf '#[fg=colour83]'
elif [ "$percentage" -ge 30 ]; then
    printf '#[fg=colour178]'
else
    printf '#[fg=colour160]'
fi
