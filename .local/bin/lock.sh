#!/bin/sh
#
# lock

SOCKETS_DIR="/tmp/mpv-sockets/"

main() {
    mpc pause >/dev/null 2>&1;

    for socket in "${SOCKETS_DIR}"/*; do
        [ -e "${socket}" ] || break
        printf 'set pause yes\n' | socat - "${socket}";
    done

    bpid=$(ps -ef | grep -i "\<${BROWSER}\>" | grep -iv '\<grep\>' | awk '{ printf "%s ", $2 }')

    [ -n "${bpid}" ] && kill -STOP ${bpid}

    "${LOCKER}"

    temp="$(mktemp)"

    jobs -p > "${temp}"

    wait < "${temp}"

    kill -CONT ${bpid}
}

main "${@}"
