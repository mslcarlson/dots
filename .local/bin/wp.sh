#!/bin/sh
#
# wp

WP="${XDG_DATA_HOME:-${HOME}/.local/share}/wp"
COLORS="${XDG_CACHE_HOME:-${HOME}/.cache}/wal/colors.sh"
DEFAULTBG=259
XRESOURCES="${XDG_CONFIG_HOME:-${HOME}/.config}/x/xresources"

get_rand_file() {
    flag=1

    files="$(for file in "${1}"/*; do
                [ -d "${file}" ] && continue
                printf '%s\n' "${file}"
            done)"

    file=''
    while ! check_file "${file}"; do
        file="$(printf '%s' "${files}" | shuf -n 1)"
        files="$(printf '%s' "${files}" | grep -vw "${file}")"
        [ -z "${files}" ] && break
    done

    if ! check_file "${file}"; then file=''; fi
    [ -z "${file}" ] && flag=1 || flag=0

    return ${flag}
}

check_file () {
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
      | xpm) return 0 ;;
        *)   return 1 ;;
    esac
}

wp () {
    ln -sf "${file}" "${WP}"
    feh --no-fehbg --bg-scale "${WP}"
    command -v wal >/dev/null && theme
}

theme() {
    wal -c && wal -i "${WP}"
    [ -f "${COLORS}" ] && . "${COLORS}"

    set -- ${color0} ${color1} ${color3} ${color4} ${color5} ${color6} ${color7} ${color8} \
           ${color9} ${color10} ${color11} ${color12} ${color13} ${color14} ${color15}

    i=0
    for color in "${@}"; do
        color="$(printf '%s' "${color}" | tr '[:upper:]' '[:lower:]')"
        sed -i "s/#define col${i} .*/#define col${i} ${color}/" "${XRESOURCES}"
        i=$((i+1))
        [ ${i} -eq 16 ] && break
    done

    xrdb -merge "${XRESOURCES}"

    kill -s USR1 $(pidof st)

    for tty in $(ls /dev/pts/ | egrep -i '[1-9][0-9]*'); do
        printf "\033]4;${DEFAULTBG};${color0}\007" > "/dev/pts/${tty}" 2>/dev/null
    done

    dwmc reload
}

{ [ -d "${1}" ] && get_rand_file "${1}" && flag=${?} ; } || { [ -f "${1}" ] && check_file "${1}" && flag=${?} ; }

[ ${flag} = "0" ] && [ -n "${file}" ] && wp "${file}"
