#!/bin/sh
#
# monitor

ICON=''
# brightness vcp code is 10
VCP_CODE=10
# cache used b/c ddcutil getvcp too expensive
BRIGHTNESS="${XDG_CACHE_HOME:-${HOME}/.cache}/bar/brightness"

get_brightness() {
    [ ! -f "${BRIGHTNESS}" ] && return
    # brightness cache should contain only number
    ! brightness=$(cat ${BRIGHTNESS} | grep '^[0-9][0-9]*$') && return

}

set_brightness() {
    get_brightness

    # keep between 0-100
    [ "${1}" = '+' ] && [ ${brightness} -ge 100 ] && return
    [ "${1}" = '-' ] && [ ${brightness} -le 0 ] && return

    brightness=$((${brightness} ${1} ${2}))

    # set brightness using ddcutil
    doas ddcutil setvcp ${VCP_CODE} ${brightness} >/dev/null 2>&1

    # get actual brightness and send output to cache
    printf '%s\n' "$(doas ddcutil getvcp ${VCP_CODE} | awk '{ print $9 }' | tr -d '[:punct:]')" 2>/dev/null > "${BRIGHTNESS}"
}

show() {
    get_brightness
    printf '%s\n' "${ICON} ${brightness}%"
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && show

    # bar options
    case "${BLOCK_BUTTON}" in
        4) set_brightness + 25 ;;
        5) set_brightness - 25 ;;
    esac

    # set monitor brightness based on args
    # ${1} = +/- and ${2} = percentage
    [ "${*}" ] && set_brightness "${1}" "${2}"
}

main "${@}"