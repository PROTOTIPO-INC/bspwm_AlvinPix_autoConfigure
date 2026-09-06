#!/bin/bash
# rezise.sh
# Centra y dimensiona la ventana flotante enfocada.
# Usage: rezise.sh [width] [height]
# Defaults: 1050x600

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

WIDTH=${1:-1050}
HEIGHT=${2:-600}

# Get monitor resolution
monitor_size=$(xrandr | grep "primary" | awk '{print $4}')
if [ -z "$monitor_size" ]; then
    # Fallback: try connected monitors
    monitor_size=$(xrandr | grep " connected" | head -1 | awk '{print $3}')
fi

width=$(echo "$monitor_size" | cut -d'x' -f1)
height=$(echo "$monitor_size" | cut -d'x' -f2)

if [ -z "$width" ] || [ -z "$height" ]; then
    echo "Error: Could not detect monitor resolution"
    exit 1
fi

# Calculate centered position
x_pos=$((($width - $WIDTH) / 2))
y_pos=$((($height - $HEIGHT) / 2))

# Set floating and center the focused window
bspc node -t floating -g hidden=off

# Try to resize using xdotool (if available)
if which xdotool >/dev/null 2>&1; then
    xdotool getactivewindow windowsize "$WIDTH" "$HEIGHT"
    xdotool getactivewindow windowmove "$x_pos" "$y_pos"
else
    # Fallback: use bspc to move/resize
    bspc node -z "$x_pos" "$y_pos"
fi
