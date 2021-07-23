#!/bin/sh
#
# wp

WP_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/wp"

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
    feh --no-fehbg --bg-scale "${1}"
}

{ [ -d "${1}" ] && get_rand_file "${1}" && flag=${?} ; } || { [ -f "${1}" ] && check_file "${1}" && flag=${?} ; }

[ ${flag} = "0" ] && [ -n "${file}" ] && wp "${file}"
