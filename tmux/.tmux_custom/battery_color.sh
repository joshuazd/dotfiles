#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
percentage=$("$CURRENT_DIR/battery_percentage.sh" | sed 's/%//')

if [ "$percentage" -eq 100 ]; then
    printf '#[fg=green]'
elif [ "$percentage" -ge 60 ]; then
    printf '#[fg=brightgreen]'
elif [ "$percentage" -ge 30 ]; then
    printf '#[fg=yellow]'
else
    printf '#[fg=red]'
fi
