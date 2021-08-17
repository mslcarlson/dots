#!/bin/sh
#
# light

ICON=''
# intel_backlight for thinkpad at least
LIGHT='/sys/class/backlight/intel_backlight/'
# 852 on thinkpad not sure if universal
MAX_BRIGHTNESS="$([ -f "${LIGHT}/max_brightness" ] && cat "${LIGHT}/max_brightness")"

get_brightness() {
    # first get brightness as percentile of max brightness
    brightness="$(cat "${LIGHT}/brightness")"
    # then convert to percentage in terms of one hundred
    brightness="$(printf '%s\n' "scale=10; (${brightness}/${MAX_BRIGHTNESS})*100" | bc)"
    # dont care bout decimal
    brightness="$(printf '%.0f\n' "${brightness}")"
}

set_brightness() {
    get_brightness

    if [ "${1}" = '+' ]; then
        # convert brightness percentage to actual brightness units then add percentage in actual brightness units
        if [ "${brightness}" -lt 100 ]; then brightness=$(printf '%s\n' "scale=10; ((${brightness}/100)*${MAX_BRIGHTNESS})+(${2}*(${MAX_BRIGHTNESS}/100))" | bc)
        else return
        fi
    elif [ "${1}" = '-' ]; then
        # same as above but substract
        if [ "${brightness}" -gt 0 ]; then brightness=$(printf '%s\n' "scale=10; ((${brightness}/100)*${MAX_BRIGHTNESS})-(${2}*(${MAX_BRIGHTNESS}/100))" | bc)
        else return
        fi
    fi

    # can the decimal
    brightness="$(printf '%.0f\n' ${brightness})"

    # keep between 0 and max brightness
    [ ${brightness} -lt 0 ] && brightness=0
    [ ${brightness} -gt ${MAX_BRIGHTNESS} ] && brightness=${MAX_BRIGHTNESS}

    # send brightness to file for future reading
    printf '%s\n' ${brightness} > "${LIGHT}/brightness"

    env HERBE_ID=/0 herbe "Brightness: ${brightness}%"
}

bar() {
    get_brightness

    printf '%s\n' "${ICON} ${brightness}%"
}

main() {
    # run only if backlight found
    [ -d "${LIGHT}" ] || return 1

    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        4) set_brightness + 1 ;;
        5) set_brightness - 1 ;;
    esac

    # adjust brightness based on args
    # ${1} = +/- and ${2} = percentage
    [ "${*}" ] && set_brightness "${1}" "${2}"
}

main "${@}"
