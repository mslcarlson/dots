#!/bin/sh
#
# script

DICT='/usr/share/dict/british-english'
LENGTH_ERROR='String length must be a number between 1 and 64.'

is_integer() {
    case "${1}" in
        (*[!0123456789]*) return 1 ;;
        ('')              return 1 ;;
        (*)               return 0 ;;
    esac
}

main() {
    while :; do
        # get string type
        printf '%s\n' 'Type of string (0 = random, 1 = phrase)?: '
        read -r string_type
        # incorrect input
        { [ ! "${string_type}" = '0' ] && [ ! "${string_type}" = '1' ] ; } && printf '%s\n' 'String type must be a number between 0 and 1.' && continue
        break
    done

    # get string length
    while :; do
        printf '%s\n' "If you're generating a phrase, it's recommended to use a middling length, because it's very time consuming or even impossible to generate a phrase if the length is very low or very high."
        printf '%s\n' 'Length of string (1-64)?: '
        read -r length
        # test whether input is number
        ! is_integer "${length}" && printf '%s\n' "${LENGTH_ERROR}" && continue
        # test whether input is within range
        { [ "${length}" -lt 1 ] || [ "${length}" -gt 64 ] ; } && printf '%s\n' "${LENGTH_ERROR}" && continue
        break
    done

    # generate string
    string=''
    # generate random string via /dev/urandom and tr
    if [ "${string_type}" = '0' ]; then
        string="$(</dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c "${length}"; printf '\n')"
        printf '%s\n' "${string}"
    # generate random phrase by pulling words from dictionary
    elif [ "${string_type}" = '1' ]; then
        while :; do
            string="$(grep -v "'s\|[[:upper:]]" "${DICT}" | shuf -n 4 | tr -d '\n')"
            [ ${#string} -eq "${length}" ] && printf '%s\n' "${string}" && break
        done
    fi

    return 0
}

main "${@}"
