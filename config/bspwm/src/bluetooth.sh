#!/usr/bin/env bash
# Basado en gh0stzk/dotfiles (https://github.com/gh0stzk/dotfiles), GPL-3.0. Copyright (C) 2021-2026 gh0stzk. Modificado por Jimmy Falco (Jimmy4TK), 2026.

#	Jimmy4TK- https://github.com/Jimmy4TK/WorkSpace

if [ ! -d /sys/class/bluetooth ]; then
	echo # No Bluetooth interface
	exit 0
fi

# Colors
FILE="$HOME/.config/bspwm/jimmy/config.ini"
POWER_ON=$(awk '/^blue =/ {print $3; exit}' "$FILE")
POWER_OFF=$(awk '/^grey =/ {print $3; exit}' "$FILE")

# Check if Bluetooth interface exists and its status
check_bluetooth() {
	if systemctl is-active --quiet bluetooth.service; then
		if bluetoothctl show | grep -q "Powered: yes"; then
			echo "%{F$POWER_ON}󰂯%{F-}" # Bluetooth is on
		else
			echo "%{F$POWER_OFF}󰂲%{F-}" # Bluetooth is off
		fi
	else
		echo
	fi
}

check_bluetooth
