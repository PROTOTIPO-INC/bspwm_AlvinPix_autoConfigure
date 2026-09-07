#!/bin/bash
# lock.sh
# Bloqueo de pantalla con i3lock-color personalizado.
# Fondo: cache de betterlockscreen (si existe), si no el wallpaper del
# tema activo (~/.themes/<tema>/wallpapers/wal-0.png).
# Colores de acento tomados del tema activo (colors.ini).
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
RING_WIDTH=4

# --- fondo ---
CACHE_DIR="$HOME/.cache/betterlockscreen"
# Pon aqui la ruta de tu wallpaper si quieres un fondo propio en el lock.
# Dejalo vacio ("") para usar, en orden: imagenes aleatorias de
# ~/scripts/lock/ -> cache de betterlockscreen -> wal-0 del tema activo.
LOCK_IMAGE=""

# --- fondo: 1) LOCK_IMAGE, 2) ~/scripts/lock/*.png al azar, 3) cache, 4) tema ---
LOCK_IMG="$LOCK_IMAGE"
if [ -z "$LOCK_IMG" ]; then
    LOCK_DIR="$HOME/scripts/lock"
    if [ -d "$LOCK_DIR" ]; then
        mapfile -t IMGS < <(ls "$LOCK_DIR"/*.png 2>/dev/null)
        [ ${#IMGS[@]} -gt 0 ] && LOCK_IMG="${IMGS[$((RANDOM % ${#IMGS[@]}))]}"
    fi
fi
if [ -z "$LOCK_IMG" ] && [ -d "$CACHE_DIR" ]; then
    for f in "$CACHE_DIR"/*; do
        case "$f" in
            *dim*.png|*dimblur*.png|*blur*.png|*lock*.png)
                LOCK_IMG="$f"; break ;;
        esac
    done
fi
if [ -z "$LOCK_IMG" ]; then
    ACTIVE_FILE="$HOME/.config/polybar/cuts/.cache/active_theme"
    if [ -f "$ACTIVE_FILE" ]; then
        ACTIVE="$(cat "$ACTIVE_FILE" 2>/dev/null)"
        [ -f "$HOME/.themes/$ACTIVE/wallpapers/wal-0.png" ] && \
            LOCK_IMG="$HOME/.themes/$ACTIVE/wallpapers/wal-0.png"
    fi
fi

ARGS=(
    --screen 1
    --clock
    --indicator
    --force-clock
    --time-str "$TIME_STR"
    --date-str "$DATE_STR"
    --radius "$RADIUS"
    --ring-width "$RING_WIDTH"
    --ind-pos 'x+(w/2):y+(h/2)'
    --time-pos 'ix:iy-60'
    --date-pos 'ix:iy-25'
    --verif-pos 'ix:iy'
    --wrong-pos 'ix:iy'
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

if [ -n "$LOCK_IMG" ]; then
    ARGS+=( --image "$LOCK_IMG" )
fi

exec i3lock "${ARGS[@]}"