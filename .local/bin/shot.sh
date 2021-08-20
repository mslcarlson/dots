#!/bin/sh
#
# shot

COLORS="${XDG_CACHE_HOME:-${HOME}/.cache/}/wal/colors.sh"

main() {
    [ -f "${COLORS}" ] && . "${COLORS}"

    hex="$(printf '%s' "${color4}" | tr '[:lower:]' '[:upper:]' | tr -d '[:punct:]')"

    a=$(printf '%s' "${hex}" | cut -c 1-2)
    b=$(printf '%s' "${hex}" | cut -c 3-4)
    c=$(printf '%s' "${hex}" | cut -c 5-6)

    r=$(printf '%s\n' "ibase=16; ${a}" | bc)
    g=$(printf '%s\n' "ibase=16; ${b}" | bc)
    b=$(printf '%s\n' "ibase=16; ${c}" | bc)

    rf=$(printf '%s\n' "scale=10; ${r}/255" | bc)
    gf=$(printf '%s\n' "scale=10; ${g}/255" | bc)
    bf=$(printf '%s\n' "scale=10; ${b}/255" | bc)

    scrot -a "$(slop -b 3 -c "${rf}","${gf}","${bf}",1.0 -f '%x,%y,%w,%h')" -q 100 -z -C 'screenshot' "${PICTURES_DIR}/captures/%m-%d-%Y-%I-%M-%S.png"
}

main "${@}"
