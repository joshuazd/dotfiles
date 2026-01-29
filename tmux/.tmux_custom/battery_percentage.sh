#!/usr/bin/env bash

if command -v pmset &>/dev/null; then
	pmset -g batt | grep -o "[0-9]\{1,3\}%"
elif command -v acpi &>/dev/null; then
	acpi -b | grep -m 1 -Eo "[0-9]+%"
elif command -v upower &>/dev/null; then
	battery=$(upower -e | grep -m 1 battery)
	if [ -n "$battery" ]; then
		energy=$(upower -i "$battery" | awk '/energy:/ {print $2}')
		energy_full=$(upower -i "$battery" | awk '/energy-full:/ {print $2}')
		[ -n "$energy" ] && [ -n "$energy_full" ] && awk -v e="$energy" -v ef="$energy_full" 'BEGIN {printf("%d%%", (e/ef)*100)}'
	fi
fi
