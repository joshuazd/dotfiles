#!/usr/bin/env bash

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

print_battery_percentage() {
	# percentage displayed in the 2nd field of the 2nd row
	if command_exists "pmset"; then
		pmset -g batt | grep -o "[0-9]\{1,3\}%"
	elif command_exists "acpi"; then
		acpi -b | grep -m 1 -Eo "[0-9]+%"
	elif command_exists "upower"; then
		local battery=$(upower -e | grep -m 1 battery)
		if [ -z "$battery" ]; then
			return
		fi
		local energy
		local energy_full
		energy=$(upower -i $battery | awk -v nrg="$energy" '/energy:/ {print nrg+$2}')
		energy_full=$(upower -i $battery | awk -v nrgfull="$energy_full" '/energy-full:/ {print nrgfull+$2}')
		if [ -n "$energy" ] && [ -n "$energy_full" ]; then
			echo $energy $energy_full | awk '{printf("%d%%", ($1/$2)*100)}'
		fi
	elif command_exists "termux-battery-status"; then
		termux-battery-status | jq -r '.percentage' | awk '{printf("%d%%", $1)}'
	fi
}
print_battery_percentage
