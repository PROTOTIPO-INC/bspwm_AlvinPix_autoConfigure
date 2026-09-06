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
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $GHOSTDIR ; sudo bash Ghost.sh"
;;

*Falcon)
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $FALCONDIR ; bash falcon.sh"
;;

*Updates)
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $USERDIR ; sudo bash updates.sh"
;;

*Wifi)
kitty --hold -- bash -c "cd $USERDIR && bash rezise.sh; cd $USERDIR ; bash wifi.sh"
;;
        esac
