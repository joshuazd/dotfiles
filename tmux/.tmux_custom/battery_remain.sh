#!/usr/bin/env bash

battery_status() {
	if command -v pmset &>/dev/null; then
		pmset -g batt | awk -F '; *' 'NR==2 {print $2}'
	elif command -v upower &>/dev/null; then
		battery=$(upower -e | grep -m 1 battery)
		upower -i "$battery" | awk '/state/ {print $2}'
	elif command -v acpi &>/dev/null; then
		acpi -b | awk '{gsub(/,/, ""); print tolower($3); exit}'
	fi
}

battery_remaining_time() {
	local status discharging=false
	[[ $(battery_status) =~ discharging ]] && discharging=true
	
	if command -v pmset &>/dev/null; then
		status=$(pmset -g batt)
		if echo "$status" | grep -q 'no estimate'; then
			echo ' (Calculating)'
		else
			time=$(echo "$status" | grep -o '[0-9]\{1,2\}:[0-9]\{1,2\}')
			$discharging && echo " ($time left)" || echo " ($time till full)"
		fi
	elif command -v upower &>/dev/null; then
		battery=$(upower -e | grep -m 1 battery)
		if $discharging; then
			upower -i "$battery" | grep -E '(remain|time to empty)' | awk '{print " ("$(NF-1)" "$(NF)")"}'
		else
			upower -i "$battery" | grep 'time to full' | awk '{print " ("$4" "$5" till full)"}'
		fi
	elif command -v acpi &>/dev/null; then
		acpi -b | grep -m 1 -Eo "[0-9]+:[0-9]+:[0-9]+"
	fi
}

battery_remaining_time
