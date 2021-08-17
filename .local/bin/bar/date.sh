#!/bin/sh
#
# date

ICON=''

bar() { printf '%s\n' "${ICON} $(date +%Y-%m-%d)" ; }

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in 1) herbe "$(cal)" ;; esac
}

main "${@}"
