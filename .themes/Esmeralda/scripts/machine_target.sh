#!/bin/sh

TARGET_FILE=~/.config/polybar/cuts/scripts/target
MENU=~/.config/polybar/cuts/scripts/machine_menu.sh

if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
	ip_target=$(cat "$TARGET_FILE" | awk '{print $1}')
	name_target=$(cat "$TARGET_FILE" | awk '{print $2}')
	if [ "$name_target" ]; then
		echo "%{A1:$MENU:}%{F#7ae7ed}%{F#7ae7ed} $ip_target - $name_target %{A}"
	else
		echo "%{A1:$MENU:}%{F#7ae7ed}%{F#7ae7ed} $ip_target %{A}"
	fi
else
	echo "%{A1:$MENU:}%{F#7ae7ed}%{u-}%{F#7ae7ed} No target %{A}"
fi
