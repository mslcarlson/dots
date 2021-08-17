#!/bin/sh
#
# bat

# just handle one battery
BAT='/sys/class/power_supply/BAT0/'
BAT_CHARGING_ICON=''
BAT_WARNING_ICON=''
BAT_EMPTY_ICON=''
BAT_QUARTER_ICON=''
BAT_HALF_ICON=''
BAT_THREE_QUARTERS_ICON=''
BAT_FULL_ICON=''

get_energy_left() {
    energy_left="$(printf '%.2f' "$(printf '%s\n' "scale=4; ${POWER_SUPPLY_ENERGY_FULL}/${POWER_SUPPLY_ENERGY_FULL_DESIGN} * 100" | bc)")"
    env HERBE_ID=/0 herbe "Energy left: ${energy_left}%"
}

bar() {
    # prefix could be charging, warning, or both
    PREFIX=''

    # if charging then append charging icon to prefix
    [ "${POWER_SUPPLY_STATUS}" = 'Charging' ] && PREFIX="${PREFIX}${BAT_CHARGING_ICON} "

    # battery icon split into empty, quarter, half, three-quarters, and full
    case ${POWER_SUPPLY_CAPACITY} in
        0)                        ICON="${BAT_EMPTY_ICON}" && PREFIX="${PREFIX}${BAT_WARNING_ICON} "   ;;
        [1-9]|1[0-9]|2[0-5])      ICON="${BAT_QUARTER_ICON}" && PREFIX="${PREFIX}${BAT_WARNING_ICON} " ;;
        2[6-9]|3[0-9]|4[0-9]|50)  ICON="${BAT_HALF_ICON}"                                              ;;
        5[1-9]|6[0-9]|7[0-5])     ICON="${BAT_THREE_QUARTERS_ICON}"                                    ;;
        7[6-9]|8[0-9]|9[0-9]|100) ICON="${BAT_FULL_ICON}"                                              ;;
    esac

    printf '%s\n' "${PREFIX}${ICON} ${POWER_SUPPLY_CAPACITY}%"
}

main() {
    # no bat and return
    [ -d "${BAT}" ] || return 1

    # uevent holds battery variables
    [ -f "${BAT}/uevent" ] && . "${BAT}/uevent" 2>/dev/null

    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) get_energy_left ;;
    esac
}

main "${@}"
