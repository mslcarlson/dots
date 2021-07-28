#!/bin/sh
#
# wp

# wp is sym link
WP="${XDG_DATA_HOME:-${HOME}/.local/share}/wp"
# 16 colors generated by pywal
COLORS="${XDG_CACHE_HOME:-${HOME}/.cache}/wal/colors.sh"
# term fg
DEFAULTFG=259
# xresources handles suckless vars
XRESOURCES="${XDG_CONFIG_HOME:-${HOME}/.config}/x/xresources"
TMP='/tmp/xsettingsd'
FLATCOLOR="${XDG_DATA_HOME:-${HOME}/.local/share}/themes/FlatColor/gtk-3.20/gtk.css"

# get random valid file in dir
get_rand_file() {
    # get all files in dir
    files="$(for file in "${1}"/*; do
                [ -d "${file}" ] && continue
                printf '%s\n' "${file}"
            done)"

    # loop until valid file found
    file=''
    while ! check_file "${file}"; do
        # get random file and remove it from list
        file="$(printf '%s' "${files}" | awk 'BEGIN{ srand() } { printf "%f %s\n", rand(), $0 }' | sort | cut -d ' ' -f 2 | head -n 1)"
        files="$(printf '%s' "${files}" | grep -v "${file}")"

        # break if no more files to check
        [ -z "${files}" ] && break
    done

    # no files in dir are valid
    if ! check_file "${file}"; then file=''; fi

    if [ -z "${file}" ]; then return 1
    else return 0
    fi
}

check_file () {
    # get file extension
    file="${1}"
    ext="${file##*.}"

    case "${ext}" in
        # formats supported by imlib2 used by feh, sxiv, etc.
        bmp  \
      | dib  \
      | ff   \
      | gif  \
      | ico  \
      | iff  \
      | jfi  \
      | jfif \
      | jif  \
      | jpe  \
      | jpeg \
      | jpg  \
      | lbm  \
      | png  \
      | pnm  \
      | tga  \
      | tif  \
      | tiff \
      | webp \
      | xpm) return   ;;
        *)   return 1 ;;
    esac
}

wp () {
    # create wp sym link
    ln -sf "${file}" "${WP}"

    # change bg
    feh --no-fehbg --bg-scale "${WP}"

    # theme iff pywal installed
    command -v wal >/dev/null && theme
}

theme() {
    # remove cached themes
    wal -c

    # gen new theme with wpg (uses pywal)
    wpg -a "${file}" && wpg -ns "${file}"

    # fix colors for gtk
    printf '%s\n' "$(sed 's/\@define-color selected_bg_color.*/\@define-color selected_bg_color @color2;/g' "${FLATCOLOR}")" > "${FLATCOLOR}"

    # xsettingsd to live reload gtk with correct color
    printf "Net/ThemeName \"FlatColor\"" > "${TMP}"
    xsettingsd -c "${TMP}" &

    [ -f "${COLORS}" ] && . "${COLORS}"

    set -- "${color0}" "${color1}" "${color2}" "${color3}" "${color4}" "${color5}" "${color6}" "${color7}" \
           "${color8}" "${color9}" "${color10}" "${color11}" "${color12}" "${color13}" "${color14}" "${color15}"

    # replace colors in xresources
    i=0
    for color in "${@}"; do
        color="$(printf '%s' "${color}" | tr '[:upper:]' '[:lower:]')"
        printf '%s\n' "$(sed "s/#define col${i} .*/#define col${i} ${color}/" "${XRESOURCES}")" > "${XRESOURCES}"
        i=$((i+1))
        [ ${i} -eq 16 ] && break
    done

    # reload xresources
    xrdb "${XRESOURCES}"

    # reload all instances of term
    kill -s USR1 $(ps -ef | grep "\<${TERMINAL}\>" | grep -v "\<grep\>" | awk '{ printf "%s ", $2 }')

    # hacky work-around to change terminal fg on the fly
    # buggy with alpha
    for tty in $(find /dev/pts/ -name '*' | grep '[1-9][0-9]*' | tr -d '[:alpha:][=/=]'); do
        echo "\033]4;${DEFAULTFG};${color0}\007" > "/dev/pts/${tty}" 2>/dev/null
    done

    # reload dwm
    dwmc reload

    # zathura
    zathura-pywal

    # rm xsettingsd tmp later b/c it complains otherwise
    rm -f "${TMP}"
}

main() {
    # convert relative to abs if not already
    case "${1}" in
        /*) path="${1}"        ;;
        *)  path="${PWD}/${1}" ;;
    esac

    # if dir get rand file
    if [ -d "${path}" ]; then
        get_rand_file "${path}" && wp "${file}"
    # if file check it
    elif [ -f "${path}" ]; then
        check_file "${path}" && wp "${file}"
    else return 1
    fi
}

main "${@}"
