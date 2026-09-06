#!/bin/bash

# Author: Enríquez González https://github.com/AlvinPix
# Menú de acciones sobre el target de pentesting.
# Se abre al hacer click (A1) en el módulo htb_target de la polybar.

TARGET_FILE="$HOME/.config/polybar/cuts/scripts/target"
SET_TARGET="$HOME/scripts/set_target.sh"

Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'

if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
	IP=$(cat "$TARGET_FILE" | awk '{print $1}')
	NAME=$(cat "$TARGET_FILE" | awk '{print $2}')
else
	IP=""
	NAME=""
fi

if [ -z "$IP" ]; then
	action=$(printf "Set target|%s\nQuit" "$SET_TARGET" | rofi -dmenu -p "Target: none" -i)
else
	action=$(printf "Copy IP|brew\nCopy both|%s\nClear target\nManage|%s\nQuit" "$IP $NAME" "$SET_TARGET" | rofi -dmenu -p "Target: $IP $NAME" -i)
fi

case "$action" in
	"Copy IP")
		echo "$IP" | xclip -selection clipboard
		;;
	"Copy both")
		echo "$IP $NAME" | xclip -selection clipboard
		;;
	"Clear target")
		rm -f "$TARGET_FILE"
		;;
	"Set target"*)
		kitty -e "$SET_TARGET" &
		;;
	"Manage"*)
		kitty -e "$SET_TARGET" &
		;;
	*) ;;
esac
