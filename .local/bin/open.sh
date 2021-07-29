#!/bin/sh -e
#
# open

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
        "${MEDIA_PLAYER}" --no-video "${opt}"
    ;;

    # document
    *.djvu \
  | *.epub \
  | *.pdf)
        "${READER}" "${opt}"
    ;;

    # gif
    *.gif)
        "${MEDIA_PLAYER}" --loop "${opt}"
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
        "${MEDIA_PLAYER}" "${opt}"
    ;;

    # web/vector
    *.htm   \
  | *.html  \
  | *.php   \
  | *.svg   \
  | *.xhtml)
        "${BROWSER}" "${opt}"
    ;;

    # everything else
    *)
        exec "${EDITOR:-vi}" "${opt}" </dev/tty
    ;;
esac
