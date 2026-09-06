#!/bin/sh

TARGET_FILE=~/.config/polybar/cuts/scripts/target
MENU=~/.config/polybar/cuts/scripts/machine_menu.sh

if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
	ip_target=$(cat "$TARGET_FILE" | awk '{print $1}')
	name_target=$(cat "$TARGET_FILE" | awk '{print $2}')
	if [ "$name_target" ]; then
		echo "%{A1:$MENU:}%{F#e0e5e4}%{F#e0e5e4} $ip_target - $name_target %{A}"
	else
		echo "%{A1:$MENU:}%{F#e0e5e4}%{F#e0e5e4} $ip_target %{A}"
	fi
else
	echo "%{A1:$MENU:}%{F#e0e5e4}%{u-}%{F#e0e5e4} No target %{A}"
fi
