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

# VARIABLES DATABASE
USERNAME=$(whoami)
THEMEDIR="/home/${USERNAME}/.themes"
POLYDIR="/home/${USERNAME}/.config/polybar/cuts"
CONDIR="/home/${USERNAME}"

# TRAPS CTRL-C
trap ctrl_c INT

# EXIT THE SCRIPT CTRL-C
function ctrl_c () {
echo ""
echo ""
echo -e "${Blue} ${White}[${Cyan}i${White}] Exiting the theming script"
exit 0
}

# BANNER THE SCRIPT
banner () {
echo -e "${White} ╔────────────────────────────────────────────────────────────────────╗     		  		  "
echo -e "${White} |${Blue} ████████╗██╗  ██╗███████╗ █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ ${White} |    		  "
echo -e "${White} |${Blue} ╚══██╔══╝██║  ██║██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔════╝ ${White} |     		  "
echo -e "${White} |${Blue}    ██║   ███████║█████╗  ███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗${White} |    		  "
echo -e "${White} |${Blue}    ██║   ██╔══██║██╔══╝  ██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║${White} |    	          "
echo -e "${White} |${Blue}    ██║   ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝${White} |    	          "
echo -e "${White} |${Blue}    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ${White} |    	          "
echo -e "${White} ┖────────────────────────────────────────────────────────────────────┙    		 	          "
echo -e "${Blue} ${White}[${Cyan}i${White}] Welcome ${Red}${USERNAME}${White} to theme launcher and mode! 		  "
echo -e "${Blue} ${White}[${Cyan}i${White}] If you want to exit the script use ${Red}[CTRL+C]                             "
echo -e "${Blue} ${White}[${Cyan}i${White}] What type of theme do you want to apply? 			  		  "
}

# LIST OF AVAILABLE THEMES (index starts at 1)
THEMES=(Zenitsu Raven Simon Camila Ryan Esmeralda Xavier Nami)

# SHOW THEMES MENU
themes_menu () {
echo ""
echo -e "${Blue} ${White}[${Cyan}i${White}] Loading themes ${mode_name}..."
echo ""
local i
for i in "${!THEMES[@]}"; do
	echo -e "${Blue} [${Cyan}$((i+1))${Blue}] ${THEMES[$i]}"
done
echo ""
}

# APPLY A SINGLE THEME
# apply_theme <theme_name> <mode>
apply_theme () {
local theme="$1"
local mode="$2"
local tdir="${THEMEDIR}/${theme}"

echo ""
if [ "$mode" = "normal" ]; then
	echo -e " ${White}[${Cyan}i${White}] Loading theme ${Red}[${theme}]${NC}"
	cd ${tdir}/kitty
	cp color.ini ${CONDIR}/.config/kitty
	cd ${tdir}
	cp bspwmrc ${CONDIR}/.config/bspwm
	cd ${tdir}/polybar
	cp user_modules.ini colors.ini config.ini ${CONDIR}/.config/polybar/cuts
	cp colors.rasi ${CONDIR}/.config/polybar/cuts/scripts/rofi
else
	echo -e " ${White}[${Cyan}i${White}] Loading theme penetration mode ${Red}[${theme}]${NC}"
	cd ${tdir}/kitty
	cp color.ini ${CONDIR}/.config/kitty
	cd ${tdir}
	cp bspwmrc ${CONDIR}/.config/bspwm
	cd ${tdir}/polybar
	cp user_modules.ini colors.ini ${CONDIR}/.config/polybar/cuts
	cp colors.rasi ${CONDIR}/.config/polybar/cuts/scripts/rofi
	cd ${tdir}/bar_pentest
	cp config.ini ${CONDIR}/.config/polybar/cuts
	cd ${tdir}/scripts
	cp ethernet_status.sh machine_target.sh vpn_status.sh ${CONDIR}/.config/polybar/cuts/scripts
	# Copia los scripts de gestion de target desde el area comun (~/scripts)
	cp ${CONDIR}/scripts/machine_menu.sh ${CONDIR}/scripts/set_target.sh ${CONDIR}/.config/polybar/cuts/scripts/
fi

# Colorear cava segun el tema (el foreground hex fuerza modo ncurses automatico)
CAVA_CFG="${CONDIR}/.config/cava/config"
CAVA_FG="$(grep -E '^foreground' ${tdir}/kitty/color.ini | awk '{print $2}')"
if [ -f "${CAVA_CFG}" ] && [ -n "${CAVA_FG}" ]; then
	sed -i "s/^foreground = .*/foreground = '${CAVA_FG}'/" "${CAVA_CFG}"
fi

# Colorear la barra de pestañas de kitty segun el accent del tema
KITTY_CFG="${CONDIR}/.config/kitty/kitty.conf"
ACCENT="$(grep -E '^accent' ${tdir}/polybar/colors.ini | tr -s ' ' | cut -d' ' -f3)"
if [ -f "${KITTY_CFG}" ] && [ -n "${ACCENT}" ]; then
	sed -i "s/^active_tab_background .*/active_tab_background ${ACCENT}/" "${KITTY_CFG}"
	sed -i "s/^inactive_tab_background .*/inactive_tab_background ${ACCENT}/" "${KITTY_CFG}"
	sed -i "s/^active_tab_foreground .*/active_tab_foreground #000000/" "${KITTY_CFG}"
fi

# Guardar tema activo para selector_random_wallpaper.sh
mkdir -p ${CONDIR}/.cache
echo "${theme}" > ${CONDIR}/.cache/active_theme

echo ""
if command -v betterlockscreen >/dev/null 2>&1; then
	betterlockscreen -u ${tdir}/wallpapers/wal-0.png
else
	echo -e "${Blue} ${White}[${Yellow}!${White}] betterlockscreen no esta instalado, se omite el lock wallpaper"
fi
echo ""
bspc wm -r
#polybar-msg cmd restart
echo -e " ${White}[${Cyan}i${White}] ${Red}[${theme}]${White} theme applied correctly (${mode} mode)"
sleep 2
exit 0
}

# SELECT A THEME FROM A LIST
select_theme () {
local mode="$1"
local choice

themes_menu
echo -ne "${Blue} ▶ ${Red}"
read choice

case "$choice" in
	''|*[!0-9]*)	# not a number
		echo ""
		echo -e "${Blue} ${White}[${Cyan}i${White}] Invalid option, use numbers"
		sleep 2
		select_theme "$mode"
		;;
	*)
		if [ "$choice" -ge 1 ] && [ "$choice" -le "${#THEMES[@]}" ]; then
			apply_theme "${THEMES[$((choice-1))]}" "$mode"
		else
			echo ""
			echo -e "${Blue} ${White}[${Cyan}i${White}] Invalid option, use numbers"
			sleep 2
			select_theme "$mode"
		fi
		;;
esac
}

# THEAMING MODE SELECTOR
mode () {
clear
echo ""
banner
echo ""
echo -e "${Blue} [${Cyan}1${Blue}] Normal mode"
echo ""
echo -e "${White}  In this mode you can apply themes in normal mode."
echo -e "${White}  ideal for use while studying or playing."
echo ""
echo -e "${Blue} [${Cyan}2${Blue}] Penetration mode"
echo ""
echo -e "${White}  In this mode you can apply themes, but with an ideal penetration mode."
echo -e "${White}  To pentent HackTheBox, VulnHub, TryHackMe."
echo ""
echo -ne "${Blue} ▶ ${Red}"
read mode
case $mode in

1)
mode_name="normal mode"
select_theme normal ;;

2)
mode_name="penetration mode"
# Integracion con pentest_setup.sh: solo preguntar si hay herramientas faltantes
MISSING="$(bash ${CONDIR}/scripts/pentest_setup.sh --check-missing 2>/dev/null)"
if [ -z "${MISSING}" ]; then
	echo ""
	echo -e "${Blue} ${White}[${Cyan}i${White}] Pentest tools already installed"
else
	echo ""
	echo -e "${Blue} ${White}[${Yellow}!${White}] Some pentest tools are missing:"
	echo -e "${White}    ${MISSING}"
	echo -e "${Blue} ${White}[${Cyan}i${White}] Do you want to install them now?"
	echo -ne "${Blue} ${White}[${Red}Y/n${White}] ▶ "
	read setup_opt
	case "$setup_opt" in
		n|N)
			echo -e "${Blue} ${White}[${Cyan}i${White}] Skipping pentest tools setup"
			;;
		*)
			sudo bash ${CONDIR}/scripts/pentest_setup.sh
			;;
	esac
fi
select_theme pentest ;;

*)
echo ""
echo -e "${Blue} ${White}[${Cyan}i${White}] Invalid option, use numbers"
sleep 2
mode
esac
}

# CALL MENUS THE SCRIPT THEMES AND RESET
reset
mode
