#!/bin/bash
# lock.sh
# Bloqueo de pantalla con i3lock-color personalizado.
# Usa el color de acento del tema activo (colors.ini) y el cache
# de betterlockscreen como fondo diffumado si existe.
#
# Todo editable desde las variables de abajo ->


# colores rrggbbaa (alpha al final). El acento se toma del tema activo.
ACCENT="#3497FD"
if [ -f ~/.config/polybar/cuts/colors.ini ]; then
    ACCENT=$(grep -oP '^\s*primary\s*=\s*\K\S+' ~/.config/polybar/cuts/colors.ini | head -1)
    [ -z "$ACCENT" ] && ACCENT="#3497FD"
fi
A="${ACCENT#\#}"

# colores del lock (8 hex: RRGGBBAA)
RING_COLOR="${A}ff"        # anillo en reposo
INSIDE_COLOR="00000000"    # interior transparente
LINE_COLOR="00000000"      # linea entre anillo e interior
TEXT_COLOR="ffffffcc"      # textos principales
WRONG_COLOR="f04342ff"     # anillo al fallar (rojo)
INSIDE_WRONG="f0434244"    # interior al fallar
KEYHL_COLOR="${A}ff"       # arco al teclear
BSHL_COLOR="e57373ff"      # arco al borrar
VERIF_COLOR="ffffffcc"     # texto mientras verifica

# textos
VERIF_TEXT="Verificando..."
WRONG_TEXT="Contrasena incorrecta"
NOINPUT_TEXT=""
GREETER_TEXT=""            # oculta el "Type your password"; pon texto o dejalo vacio

# reloj/fecha
TIME_STR="%H:%M:%S"
DATE_STR="%A, %d de %B"

# tamano del indicador
RADIUS=90
RING_WIDTH=7

LOCK_IMG=""
CACHE_DIR="$HOME/.cache/betterlockscreen"
for cand in "$CACHE_DIR/$(whoami)-dim.png" "$CACHE_DIR/$(whoami)-dimblur.png" "$CACHE_DIR/$(whoami)-lock.png" "$CACHE_DIR/$(whoami)-blur.png"; do
    [ -f "$cand" ] && LOCK_IMG="$cand" && break
done

ARGS=(
    --image "$LOCK_IMG"
    --screen 1
    --clock
    --indicator
    --force-clock
    --time-str "$TIME_STR"
    --date-str "$DATE_STR"
    --radius "$RADIUS"
    --ring-width "$RING_WIDTH"
    --insidever-color 00000000
    --ringver-color "${A}ff"
    --insidewrong-color "$INSIDE_WRONG"
    --ringwrong-color "$WRONG_COLOR"
    --inside-color "$INSIDE_COLOR"
    --ring-color "$RING_COLOR"
    --line-color "$LINE_COLOR"
    --separator-color "$RING_COLOR"
    --verif-color "$VERIF_COLOR"
    --wrong-color "$WRONG_COLOR"
    --time-color "$TEXT_COLOR"
    --date-color "$TEXT_COLOR"
    --layout-color "$TEXT_COLOR"
    --keyhl-color "$KEYHL_COLOR"
    --bshl-color "$BSHL_COLOR"
    --verif-text "$VERIF_TEXT"
    --wrong-text "$WRONG_TEXT"
    --noinput-text "$NOINPUT_TEXT"
    --greeter-text "$GREETER_TEXT"
    --no-modkey-text
)

if [ -z "$LOCK_IMG" ]; then
    # sin imagen: fondo del color del tema
    ARGS+=( --color "${A}ee" )
fi

exec i3lock "${ARGS[@]}"