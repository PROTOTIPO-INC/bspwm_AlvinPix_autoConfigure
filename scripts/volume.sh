#!/bin/sh
# volume.sh
# PulseAudio Volume Control Script
# Usage: volume.sh [up|down|mute]

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) [up|down|mute]"
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
    *)
        echo "Usage: $(basename $0) [up|down|mute]"
        exit 1
        ;;
esac
