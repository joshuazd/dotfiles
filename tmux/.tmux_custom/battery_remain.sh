#!/usr/bin/env bash

# CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source "$CURRENT_DIR/battery.tmux"

short=false

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

battery_status() {
	if command_exists "pmset"; then
		pmset -g batt | awk -F '; *' 'NR==2 { print $2 }'
	elif command_exists "upower"; then
		local battery
		battery=$(upower -e | grep -m 1 battery)
		upower -i $battery | awk '/state/ {print $2}'
	elif command_exists "acpi"; then
		acpi -b | awk '{gsub(/,/, ""); print tolower($3); exit}'
	elif command_exists "termux-battery-status"; then
		termux-battery-status | jq -r '.status' | awk '{printf("%s%", tolower($1))}'
	fi
}

get_remain_settings() {
	short=$(get_tmux_option "@batt_remain_short" false)
}

battery_discharging() {
	local status="$(battery_status)"
	[[ $status =~ (discharging) ]]
}

pmset_battery_remaining_time() {
	local status="$(pmset -g batt)"
	if echo $status | grep 'no estimate' >/dev/null 2>&1; then
		# if $short; then
		# 	echo '~?:??'
		# else
                echo ' (Calculating estimate)'
		# fi
	else
		local remaining_time="$(echo $status | grep -o '[0-9]\{1,2\}:[0-9]\{1,2\}')"
		if battery_discharging; then
			# if $short; then
			# 	echo $remaining_time | awk '{printf "~%s", $1}'
			# else
                        echo $remaining_time | awk '{printf " (%s left)", $1}'
			# fi
		else
			# if [ ! $short ]; then
                        echo $remaining_time | awk '{printf " (%s till full)", $1}'
			# fi
		fi
	fi
}

print_battery_remain() {
	if command_exists "pmset"; then
		pmset_battery_remaining_time
	elif command_exists "upower"; then
		battery=$(upower -e | grep -m 1 battery)
		# if is_chrome; then
		# 	if battery_discharging; then
		# 		upower -i $battery | grep 'time to empty' | awk '{printf "- %s %s left", $4, $5}'
		# 	else
		# 		upower -i $battery | grep 'time to full' | awk '{printf "- %s %s till full", $4, $5}'
		# 	fi
		# else
        fulltime=$(upower -i $battery | grep -E '(remain|time to empty)' | awk '{print $(NF-1)}')
        minutes=$(echo "$fulltime" | awk '{ printf("%02d", ($1 % 1) * 60) ; }')
        hours=$(echo "$fulltime" | awk '{ split($1, a, "."); print a[1] }')
        if [ "$fulltime" = "" ]; then
            echo ""
        else
            echo " ($hours:$minutes)"
        fi
		# fi
	elif command_exists "acpi"; then
		acpi -b | grep -m 1 -Eo "[0-9]+:[0-9]+:[0-9]+"
	fi
}

print_battery_full() {
	# if !$short; then
	# 	return
	# fi

	if command_exists "pmset"; then
		pmset_battery_remaining_time
	elif command_exists "upower"; then
		battery=$(upower -e | grep -m 1 battery)
                upower -i $battery | grep 'time to full' | awk '{printf " (%s %s till full)", $4, $5}'
    
	fi
}

main() {
	get_remain_settings
	if battery_discharging; then
		print_battery_remain
	else
		# if [ ! $short ]; then
			print_battery_full
		# fi
	fi
}
main
