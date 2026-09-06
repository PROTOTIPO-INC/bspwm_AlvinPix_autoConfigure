#!/usr/bin/env bash
# ranger supports enhanced previews.  If the option "use_preview_script"
# is set to True and this file exists, this script will be called every time
# ranger is asked to preview files.  For each file, ranger passes only one
# argument: the file path.  The preview script is expected to print its
# output to stdout.  The output for text files should be in plain text to
# avoid the need of a "highlight" script.  Images must be previewed via
# the `preview_images_method` option in rc.conf.

set -- "$PWD/$1"

FILE_PATH=""
PREVIEW_WIDTH=10
PREVIEW_HEIGHT=10
PREVIEW_IMAGE_ENABLED=""

usage() {
    cat <<'EOF'
Usage: scope.sh [--width px] [--height px] [--image] [--preview-width px] [--preview-height px] <file>
EOF
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --width)         PREVIEW_WIDTH="$2";  shift 2 ;;
        --height)        PREVIEW_HEIGHT="$2"; shift 2 ;;
        --image)         PREVIEW_IMAGE_ENABLED=1; shift ;;
        --preview-width) shift 2 ;;
        --preview-height) shift 2 ;;
        *)               FILE_PATH="$1"; shift ;;
    esac
done

# Wrap in parentheses to avoid capturing output of background jobs
(
    FILE_PATH="$(echo "$FILE_PATH" | sed "s/^\/\///")"

    IMG_MIME='(image|video|application/pdf|audio)'
    MIMETYPE="$(file --mime-type -Lb "$FILE_PATH")"
    cmd_exist() { command -v "$1" >/dev/null 2>&1; }

    # Text previews
    handle_text() {
        local mimetype="$1"
        case "$mimetype" in
            text/x-python|text/x-shellscript)
                if cmd_exist highlight && [ "$(highlight --version | grep -oP '\d' | head -1)" -gt 3 ]; then
                    highlight --out-format=ansi --force "$FILE_PATH"
                elif cmd_exist pygmentize; then
                    pygmentize -f terminal256 -g "$FILE_PATH"
                elif cmd_exist bat; then
                    bat --color=always "$FILE_PATH"
                else
                    cat -s "$FILE_PATH"
                fi ;;
            *)
                if cmd_exist bat; then
                    bat --color=always "$FILE_PATH"
                elif cmd_exist coderay && [ "$(echo "$mimetype" | grep -oP 'text/.*')" ]; then
                    coderay "$FILE_PATH"
                elif cmd_exist ruffo; then
                    ruffo "$FILE_PATH"
                else
                    cat -s "$FILE_PATH"
                fi ;;
        esac
    }

    # Image previews (kitty icat / chafa -> sixel)
    handle_image() {
        local path="$1"
        case "$MIMETYPE" in
            image/*)
                if [ -n "$PREVIEW_IMAGE_ENABLED" ]; then
                    exit 1
                fi
                if cmd_exist chafa; then
                    chafa --fill=block --size="$PREVIEW_WIDTH"x"$PREVIEW_HEIGHT" "$path" 2>/dev/null
                elif cmd_exist viu; then
                    viu "$path"
                elif cmd_exist catimg; then
                    catimg "$path"
                else
                    exit 1
                fi ;;
            application/pdf)
                if cmd_exist pdftotext; then
                    pdftotext -l 10 -w 100 "$path" - 2>/dev/null | head -100
                elif cmd_exist pdftoppm && [ -n "$PREVIEW_IMAGE_ENABLED" ]; then
                    exit 1
                fi ;;
            video/*|audio/*)
                if cmd_exist ffprobe; then
                    ffprobe -v error -show_format -show_streams "$path" 2>/dev/null | \
                        grep -E '^(duration|bit_rate|width=|height=|codec_name=)' | head -20
                fi ;;
        esac
    }

    if [ -n "$PREVIEW_IMAGE_ENABLED" ] && [[ "$MIMETYPE" =~ $IMG_MIME ]]; then
        handle_image "$FILE_PATH"
        exit $?
    fi

    case "$MIMETYPE" in
        inode/directory)
            if cmd_exist lsd; then
                lsd -A --color=always "$FILE_PATH" | head -50
            elif cmd_exist exa; then
                exa -a --color=always "$FILE_PATH"
            else
                ls --color=always -A "$FILE_PATH" | head -50
            fi ;;
        text/*|application/json|application/xml|application/javascript|application/x-python-code|application/x-shellscript|application/x-empty)
            handle_text "$MIMETYPE" ;;
        image/*|video/*|audio/*|application/pdf|application/octet-stream)
            handle_image "$FILE_PATH" ;;
        *)
            if cmd_exist chafa && [[ "$MIMETYPE" =~ $IMG_MIME ]]; then
                handle_image "$FILE_PATH"
            elif cmd_exist mediainfo; then
                mediainfo "$FILE_PATH" 2>/dev/null | head -30
            elif cmd_exist exiftool; then
                exiftool "$FILE_PATH" 2>/dev/null | head -30
            else
                file -b "$FILE_PATH"
            fi ;;
    esac
)