#!/bin/sh
#
# pin

get_pin() {
    prompt='Pin'

    # get pin using dmenu and check
    if pin="$(dmenu -c -p "${prompt}" -P 2>/dev/null)"; then
        [ -n "${pin}" ] && printf '%s\n' "D ${pin}"
        printf 'OK\n'
    # operation cancelled
    else printf 'ERR 99\n'
    fi
}

main() {
    # export display
    if [ -z "${DISPLAY}" ]; then
        DISPLAY=':1'
        export DISPLAY
    fi

    # start msg
    printf 'OK Pleased to meet you\n'

    # ipc
    while read -r line; do
        # cmds needed to interface with pinentry
        cmd="$(printf '%s\n' "${line}" | cut -d ' ' -f 1)"

        case "${cmd}" in
            # GETPIN is command pinentry uses for GNUPG pass
            GETPIN) get_pin       ;;
            *)      printf 'OK\n' ;;
        esac
    done
}

main "${@}"
