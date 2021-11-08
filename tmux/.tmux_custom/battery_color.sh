#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

battery_color_fg() {
	percentage=$($CURRENT_DIR/battery_percentage.sh | sed -e 's/%//')
    if [ $percentage -eq 100 ]; then
        printf '#[fg=colour62]'
    elif [ $percentage -le 99 -a $percentage -ge 60 ]; then
        printf '#[fg=colour83]'
    elif [ $percentage -le 59 -a $percentage -ge 30 ]; then
        printf '#[fg=colour178]'
    else
        printf '#[fg=colour160]'
    fi
}
battery_color_fg
