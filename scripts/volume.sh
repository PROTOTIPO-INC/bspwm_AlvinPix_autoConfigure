#!/bin/bash
# volume.sh
# PulseAudio Volume Control Script
# Usage: volume.sh [up|down|mute|status]

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) [up|down|mute|status]"
    exit 65
fi

VOLSTEP=5 # 5% incremental

# Get default sink ID
DEFAULT_SINK=$(pactl get-default-sink 2>/dev/null)
if [ -z "$DEFAULT_SINK" ]; then
    # Fallback: try pactl info
    DEFAULT_SINK=$(pactl info | grep "Default Sink" | awk '{print $3}')
fi

# Get current volume percentage for default sink
getvol() {
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 | tr -d '%')
    if [ -z "$VOL" ]; then
        VOL=0
    fi
}

# Get mute state
getmute() {
    MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o "yes\|no")
}

getvol

up() {
    NEWVOL=$((VOL + VOLSTEP))
    if [ "$NEWVOL" -gt 100 ]; then
        NEWVOL=100
    fi
    pactl set-sink-volume @DEFAULT_SINK@ "${NEWVOL}%"
}

down() {
    NEWVOL=$((VOL - VOLSTEP))
    if [ "$NEWVOL" -lt 0 ]; then
        NEWVOL=0
    fi
    pactl set-sink-volume @DEFAULT_SINK@ "${NEWVOL}%"
}

mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

status() {
    getvol
    getmute

    # color acento del tema activo (colors.ini lo actualiza el theme)
    ACCENT="#344A4B"
    if [ -f ~/.config/polybar/cuts/colors.ini ]; then
        ACCENT=$(grep -oP '^\s*primary\s*=\s*\K\S+' ~/.config/polybar/cuts/colors.ini | head -1)
        [ -z "$ACCENT" ] && ACCENT="#344A4B"
    fi

    # iconos Nerd Font: U+F026 mute/off, U+F027 low, U+F028 high
    if [ "$MUTED" = "yes" ]; then
        printf -v ICON "\uf026"
    elif [ "$VOL" -ge 67 ]; then
        printf -v ICON "\uf028"
    elif [ "$VOL" -ge 34 ]; then
        printf -v ICON "\uf027"
    else
        printf -v ICON "\uf026"
    fi

    # barras diagonales gruesas (U+27CB = ⟋), 10 segmentos
    FILL=$(( (VOL * 10) / 100 ))
    [ $FILL -lt 0 ] && FILL=0
    [ $FILL -gt 10 ] && FILL=10
    EMPTY=$(( 10 - FILL ))

    printf -v BAR "\u27cb"

    FILLED=""
    i=0
    while [ $i -lt $FILL ]; do FILLED="${FILLED}${BAR}"; i=$((i+1)); done
    EMPTIES=""
    i=0
    while [ $i -lt $EMPTY ]; do EMPTIES="${EMPTIES}${BAR}"; i=$((i+1)); done

    echo "%{F#${ACCENT#\#}}${ICON} %{F-}%{F#${ACCENT#\#}}${FILLED}%{F-}%{F#606060}${EMPTIES}%{F-}"
}

case $1 in
    up)
        up
        ;;
    down)
        down
        ;;
    mute)
        mute
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $(basename $0) [up|down|mute|status]"
        exit 1
        ;;
esac