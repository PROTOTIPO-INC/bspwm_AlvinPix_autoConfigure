#!/bin/bash

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

# Gestion del target de pentesting (HackTheBox, VulnHub, TryHackMe)
# El archivo 'target' es leido por machine_target.sh en la polybar.
# Formato del archivo:  <IP> <NOMBRE>

# COLORS THE SCRIPT
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'

# VARIABLES DATABASE
USERNAME=$(whoami)
TARGET_FILE="${HOME}/.config/polybar/cuts/scripts/target"

# TRAPS CTRL-C
trap ctrl_c INT

function ctrl_c () {
echo ""
echo -e "${Cyan} [i]${White} Exiting the target script"
exit 1
}

set_target () {
	read -p " Enter the target IP  : " ip
	read -p " Enter the target name: " name

	if [ -z "$ip" ]; then
		echo -e "${Red} [x]${White} IP cannot be empty"
		sleep 1
		return
	fi

	echo "$ip $name" > "${TARGET_FILE}"
	echo ""
	echo -e "${Green} [+]${White} Target set -> ${Red}${ip}${White} ${name}"
}

clear_target () {
	rm -f "${TARGET_FILE}"
	echo ""
	echo -e "${Yellow} [!]${White} Target cleared"
}

show_target () {
	if [ -f "${TARGET_FILE}" ]; then
		echo ""
		echo -e "${Green} [+]${White} Current target:"
		echo -e "     ${Red}$(cat "${TARGET_FILE}")${White}"
	else
		echo ""
		echo -e "${Yellow} [!]${White} No target set"
	fi
}

copy_target () {
	if [ -f "${TARGET_FILE}" ]; then
		cat "${TARGET_FILE}" | awk '{print $1}' | xclip -selection clipboard
		echo ""
		echo -e "${Green} [+]${White} Target IP copied to clipboard"
	else
		echo ""
		echo -e "${Yellow} [!]${White} No target set"
	fi
}

target_status () {
	local status="no"
	if [ -f "${TARGET_FILE}" ] && [ -s "${TARGET_FILE}" ]; then
		if pgrep -x openvpn >/dev/null 2>&1; then
			status="vpn+target"
		else
			status="target"
		fi
	fi
	echo "$status"
}

while true; do
	clear
	echo ""
	echo -e "${Cyan} ╔══════════════════════════════╗"
	echo -e "${Cyan} |${White}    TARGET MANAGEMENT ${Cyan}          |"
	echo -e "${Cyan} ╚══════════════════════════════╝"
	echo ""
	[ -f "${TARGET_FILE}" ] && [ -s "${TARGET_FILE}" ] && echo -e " ${Green} Current target: ${Red}$(cat "${TARGET_FILE}")"
	[ ! -s "${TARGET_FILE}" ] && echo -e " ${Yellow} No target set"
	echo ""
	echo -e "${Cyan} [S]${White} Set target"
	echo -e "${Cyan} [C]${White} Copy target IP to clipboard"
	echo -e "${Cyan} [V]${White} View target"
	echo -e "${Cyan} [X]${White} Clear target"
	echo -e "${Cyan} [Q]${White} Quit"
	echo ""
	echo -ne "${White} > "
	read opt
	case "$opt" in
		S|s) set_target ;;
		C|c) copy_target ;;
		V|v) show_target ;;
		X|x) clear_target ;;
		Q|q) echo ""; echo -e "${Cyan} [i]${White} Bye!"; exit 0 ;;
		*) echo -e "${Red} [x]${White} Invalid option"; sleep 1 ;;
	esac
	echo ""
	read -p " Press [ENTER] to continue..."
done
