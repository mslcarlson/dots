#!/bin/sh
#
# lock

SOCKETS_DIR="/tmp/mpv-sockets/"

for socket in "${SOCKETS_DIR}"/*; do
    [ -e "${socket}" ] || break
    printf 'set pause yes' | socat - "${socket}";
done

bpid=$(ps -ef | grep "\<${BROWSER}\>" | grep -v '\<grep\>' | awk '{ printf "%s ", $2 }')

[ -n "${bpid}" ] && kill -STOP ${bpid}

"${LOCKER}"

temp="$(mktemp)"

jobs -p > "${temp}"

wait < "${temp}"

kill -CONT ${bpid}
