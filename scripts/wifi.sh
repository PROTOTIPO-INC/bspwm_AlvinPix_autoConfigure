#!/bin/bash

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

# COLORS THE SCRIPT
Black='\033[1;30m'
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Blue='\033[1;34m'
Purple='\033[1;35m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'
blue='\033[0;34m'
white='\033[0;37m'
lred='\033[0;31m'

# traps ctrl-x
trap ctrl_c INT

# Exit ctrl-c
function ctrl_c () {
echo -e "${Cyan} [i]${White} Exiting the script"
exit 1
}

# USERNAME
user=$(whoami)

# HOST DISCOVERY (safe fallbacks)
lanip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
lanip6=$(ip -6 addr show | grep -oP '(?<=inet6\s)[0-9a-f:]+/%?\d*' | grep -v '::1' | head -1)
[ -z "$lanip" ] && lanip="N/A"
[ -z "$lanip6" ] && lanip6="N/A"

# Current connection info
current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
current_signal=$(nmcli -t -f active,SIGNAL dev wifi | grep -v '^$' | head -1)

# BANNER PRESENT THE SCRIPT
banner () {
echo -e "${White} ╔──────────────────────────────────────╗"
echo -e "${White} |${Purple} ██╗    ██╗██╗███████╗██╗${White} | ${Cyan}[󰀻 ]${White} ${lanip}"
echo -e "${White} |${Purple} ██║    ██║██║██╔════╝██║${White} | ${Cyan}[󰉺 ]${White} ${lanip6}"
echo -e "${White} |${Purple} ██║ █╗ ██║██║█████╗  ██║${White} | ${Cyan}[  ]${White} ${user}"
if [ -n "$current_ssid" ]; then
echo -e "${White} |${Purple} ██║███╗██║██║██╔══╝  ██║${White} | ${Green}[✓]${White} ${current_ssid} (${current_signal}%)"
else
echo -e "${White} |${Purple} ██║███╗██║██║██╔══╝  ██║${White} | ${Yellow}[✗]${White} Not connected"
fi
echo -e "${White} |${Purple} ╚███╔███╔╝██║██║     ██║${White} | ${Cyan}[CTRL+C]${White} Exit"
echo -e "${White} |${Purple}  ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝${White} |"
echo -e "${White} ┖──────────────────────────────────────┙"
}

# MAIN MENU
wifi () {
echo ""
clear
banner
echo ""
echo -e "${Cyan} [i]${White} Checking nmcli..."
if ! which nmcli >/dev/null 2>&1; then
	echo ""
	echo -e "${Cyan} [!]${White} nmcli not found, installing..."
	sudo apt install network-manager -y
	sleep 2
	echo -e "${Cyan} [i]${White} Installed, launch the script again!"
	exit 1
fi

echo ""
echo -e "${Cyan} [1]${White} Show nearby networks"
echo -e "${Cyan} [2]${White} Connect (open)"
echo -e "${Cyan} [3]${White} Connect with password"
echo -e "${Cyan} [4]${White} Disconnect"
echo -e "${Cyan} [5]${White} Enable WiFi"
echo -e "${Cyan} [6]${White} Disable WiFi"
echo -e "${Cyan} [7]${White} Connection status"
echo -e "${Cyan} [Q]${White} Quit"
echo ""
echo -ne "${White} > "
read wi
case $wi in
	1)
	echo ""
	nmcli dev wifi list 2>/dev/null
	;;
	2)
	echo ""
	echo -ne "${Cyan} [i]${White} Network name (SSID) > ${Red}"
	read ssid
	nmcli dev wifi connect "$ssid" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo -e "${Green} [+]${White} Connected to ${ssid}"
	else
		echo -e "${Red} [-]${White} Failed to connect (maybe needs password?)"
	fi
	;;
	3)
	echo ""
	echo -ne "${Cyan} [i]${White} Network name (SSID) > ${Red}"
	read ssid
	echo -ne "${Cyan} [i]${White} Password > ${Red}"
	read -s passwd
	echo ""
	nmcli dev wifi connect "$ssid" password "$passwd" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo -e "${Green} [+]${White} Connected to ${ssid}"
	else
		echo -e "${Red} [-]${White} Failed to connect"
	fi
	;;
	4)
	echo ""
	nmcli dev disconnect wlan0 2>/dev/null
	echo -e "${Yellow} [!]${White} Disconnected"
	;;
	5)
	echo ""
	nmcli radio wifi on
	echo -e "${Green} [+]${White} WiFi enabled"
	;;
	6)
	echo ""
	nmcli radio wifi off
	echo -e "${Yellow} [!]${White} WiFi disabled"
	;;
	7)
	echo ""
	echo -e "${Cyan} [i]${White} Connection status:"
	nmcli -t -f name,device,type,state connection show --active 2>/dev/null || nmcli general status
	echo ""
	echo -e "${Cyan} [i]${White} IP addresses:"
	ip -4 addr show | grep -E 'inet ' | grep -v '127.0.0.1'
	;;
	Q|q)
	exit 0
	;;
	*)
	echo -e "${Cyan} [!]${White} Invalid option"
	;;
esac
sleep 1
wifi
}

# CALL WIFI AND RESET
reset
wifi
