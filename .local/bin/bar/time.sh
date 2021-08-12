#!/bin/sh
#
# time

ICON=''

bar() { printf '%s\n' "${ICON} $(date +%I:%M\ %p)" ; }

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in esac
}

main "${@}"
