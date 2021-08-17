#!/bin/sh
#
# symlink

follow_link() {
    # no file provided
    [ "${1:-}" ] || return 1

    file="${1}"

    [ -e "${file%/}" ] || file=${file%"${file##*[!/]}"}
    [ -d "${file:-/}" ] && file="${file}/"

    while :; do
        if [ ! "${file}" = "${file%/*}" ]; then
            # follow with cd
            case "${file}" in
                /*) cd -P "${file%/*}/"  2>/dev/null || break ;;
                *)  cd -P "./${file%/*}" 2>/dev/null || break ;;
            esac
            file=${file##*/}
        fi

        # if not link print the actual file
        if [ ! -L "${file}" ]; then
            file="${PWD%/}${file:+/}${file}"
            printf '%s\n' "${file:-/}"
            break
        fi

        # use ls -dl to follow link
        link="$(ls -dl -- "${file}" 2>/dev/null)" || break
        file="${link#*" ${file} -> "}"
    done
}

main() { follow_link "${@}" ; }

main "${@}"
