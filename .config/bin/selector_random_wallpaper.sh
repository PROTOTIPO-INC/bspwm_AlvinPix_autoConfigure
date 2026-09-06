#!/bin/bash

# selector_random_wallpaper.sh
# Selecciona un wallpaper aleatorio del tema activo y lo aplica con feh.
# Es referenciado desde bspwmrc como auto-start.
# Para detectar el tema activo, busca el wallpaper actual en ~/.fehbg
# o usa el ultimo tema usado en ~/.cache/active_theme.

USERNAME=$(whoami)
THEMEDIR="/home/${USERNAME}/.themes"
CACHE_FILE="/home/${USERNAME}/.cache/active_theme"

get_active_theme () {
    # Intentar leer del cache
    if [ -f "$CACHE_FILE" ]; then
        local theme
        theme=$(cat "$CACHE_FILE" 2>/dev/null)
        if [ -d "$THEMEDIR/$theme/wallpapers" ]; then
            echo "$theme"
            return
        fi
    fi
    # Fallback: buscar el wallpaper actual en ~/.fehbg y cruzar con los temas
    if [ -f ~/.fehbg ]; then
        local current_wall
        current_wall=$(grep "feh" ~/.fehbg | head -1 | awk -F"'" '{print $2}' | xargs)
        for theme_dir in "$THEMEDIR"/*/; do
            local tname
            tname=$(basename "$theme_dir")
            if [ -d "$theme_dir/wallpapers" ] && ls "$theme_dir/wallpapers/" 2>/dev/null | grep -q "$(basename "$current_wall")"; then
                echo "$tname"
                return
            fi
        done
    fi
    # Fallback: primer tema disponible
    for theme_dir in "$THEMEDIR"/*/; do
        if [ -d "$theme_dir/wallpapers" ]; then
            basename "$theme_dir"
            return
        fi
    done
    echo ""
}

set_random_wallpaper () {
    local theme
    theme=$(get_active_theme)
    if [ -z "$theme" ]; then
        exit 0
    fi
    local wall_dir="$THEMEDIR/$theme/wallpapers"
    if [ ! -d "$wall_dir" ]; then
        exit 0
    fi
    local wallpapers=()
    while IFS= read -r -d '' f; do
        wallpapers+=("$f")
    done < <(find "$wall_dir" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -print0 2>/dev/null)
    if [ ${#wallpapers[@]} -eq 0 ]; then
        exit 0
    fi
    local random_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    feh --bg-scale "$random_wallpaper" 2>/dev/null
}

# Guardar el tema activo si se ejecuta desde Theaming.sh
save_theme_name () {
    local theme="$1"
    mkdir -p "$(dirname "$CACHE_FILE")"
    echo "$theme" > "$CACHE_FILE"
}

# Si se pasa un nombre de tema como argumento, guardarlo
if [ -n "$1" ]; then
    save_theme_name "$1"
fi

set_random_wallpaper
