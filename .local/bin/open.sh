#!/bin/sh -e
#
# open

main() {
    if [ ${#} -eq 0 ]; then opt="$(tee -i)"
    else opt="${*}"
    fi

    case "${opt}" in
        # audio
        *.flac \
      | *.m4a  \
      | *.mp3  \
      | *.ogg  \
      | *.opus \
      | *.wav)
            mpv --no-video "${opt}"
        ;;

        # document
        *.djvu \
      | *.epub \
      | *.pdf)
            "${READER}" "${opt}"
        ;;

        # gif
        *.gif)
            mpv --loop "${opt}"
        ;;

        # image
        *.bmp  \
      | *.dib  \
      | *.ff   \
      | *.ico  \
      | *.iff  \
      | *.jfi  \
      | *.jfif \
      | *.jif  \
      | *.jpe  \
      | *.jpeg \
      | *.jpg  \
      | *.lbm  \
      | *.png  \
      | *.pnm  \
      | *.tga  \
      | *.tif  \
      | *.tiff \
      | *.webp \
      | *.xpm)
            "${IMG_VIEWER}" "${opt}"
        ;;

        # video
        *.avi \
      | *.mkv \
      | *.mp4 \
      | *.webm)
            mpv "${opt}"
        ;;

        # web/vector
        *.htm   \
      | *.html  \
      | *.php   \
      | *.svg   \
      | *.xhtml)
            "${BROWSER}" "${opt}"
        ;;

        # torrent
        *.torrent)
            "${HOME}/.local/bin/bar/torr.sh" -a "${opt}"
        ;;

        # everything else
        *)
            exec "${EDITOR:-vi}" "${opt}" </dev/tty
        ;;
    esac
}

main "${@}"
