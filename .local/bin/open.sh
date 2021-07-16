#!/bin/sh -e
#
# open

case "${1}" in
    # audio
    *.flac \
  | *.m4a  \
  | *.mp3  \
  | *.ogg  \
  | *.opus \
  | *.wav)
        "${MEDIA_PLAYER}" --no-video "${1}"
    ;;

    # document
    *.djvu \
  | *.epub \
  | *.pdf)
        "${READER}" "${1}"
    ;;

    # gif
    *.gif)
        "${MEDIA_PLAYER}" --loop "${1}"
    ;;

    # image
    *.jpeg \
  | *.jpg  \
  | *.png  \
  | *.tga  \
  | *.webp)
        "${IMG_VIEWER}" "${1}"
    ;;

    # video
    *.avi \
  | *.mkv \
  | *.mp4 \
  | *.webm)
        "${MEDIA_PLAYER}" "${1}"
    ;;

    # web/vector
    *.htm   \
  | *.html  \
  | *.php   \
  | *.svg   \
  | *.xhtml)
        "${BROWSER}" "${1}"
    ;;

    # everything else
    *)
        "${EDITOR:-vi}" "${1}"
    ;;
esac
