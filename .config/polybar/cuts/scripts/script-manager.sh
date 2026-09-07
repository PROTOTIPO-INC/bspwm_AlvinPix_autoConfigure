#!/usr/bin/env bash

SDIR="$HOME/.config/polybar/cuts/scripts"
GHOSTDIR="${HOME}/scripts/Ghost-script"
FALCONDIR="${HOME}/scripts/Falcon"
#RESI="/home/alvinpix/Escritorio/PX-games/Scripts"
USERDIR="${HOME}/scripts"

# Launch Rofi
MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
-theme $SDIR/rofi/styles.rasi \
<<< " Ghost| Falcon| Updates| Wifi|")"
            case "$MENU" in
*Ghost)
if [ -f "${GHOSTDIR}/Ghost.sh" ]; then
	kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $GHOSTDIR ; sudo bash Ghost.sh"
else
	notify-send -u normal "Ghost-script" "Repo no instalado. Clonalo en ~/scripts/Ghost-script" 2>/dev/null
	kitty --hold -- bash -c "echo 'Ghost-script no instalado. Clona el repo en ~/scripts/Ghost-script'; read -p 'Presiona Enter para cerrar'"
fi
;;

*Falcon)
if [ -f "${FALCONDIR}/falcon.sh" ]; then
	kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $FALCONDIR ; bash falcon.sh"
else
	notify-send -u normal "Falcon" "Repo no instalado. Clonalo en ~/scripts/Falcon" 2>/dev/null
	kitty --hold -- bash -c "echo 'Falcon no instalado. Clona el repo en ~/scripts/Falcon'; read -p 'Presiona Enter para cerrar'"
fi
;;

*Updates)
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $USERDIR ; sudo bash updates.sh"
;;

*Wifi)
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $USERDIR ; bash wifi.sh"
;;
        esac
