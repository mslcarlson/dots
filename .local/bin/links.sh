#!/bin/sh
#
# links
# very similar to open.sh
# TODO: integrate this script with open.sh if i can get tee figured out

# from Objective-C regexp given on urlregex.com
URL_REGEXP="(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"

main() {
    match="$(printf '%s\n' "${@}" | grep -E "${URL_REGEXP}")"

    #shellcheck disable=SC2198
    if [ "${@}" = "${match}" ]; then
        case "${@}" in
            # audio
            *.flac \
          | *.m4a  \
          | *.mp3  \
          | *.ogg  \
          | *.opus \
          | *.wav)
                mpv --no-video "${@}"
            ;;

            # gif
            *.gif)
                mpv --loop "${@}"
            ;;

            # img
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
                "${IMG_VIEWER}" "${@}"
            ;;

            # vid
            *.avi         \
          | *.mkv         \
          | *.mp4         \
          | *.webm        \
          | *youtube.com* \
          | *youtu.be*)
                mpv "${@}"
            ;;

            # torr
            *.torrent)
                "${HOME}/.local/bin/bar/torr.sh" -a "${@}"
            ;;

            # web/vector
            *.htm   \
          | *.html  \
          | *.php   \
          | *.svg   \
          | *.xhtml \
          | *)
                "${BROWSER}" "${@}"
            ;;
        esac
    else
        return 1
    fi
}

main "${@}"
