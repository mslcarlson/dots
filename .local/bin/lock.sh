#!/bin/sh
#
# lock

SOCKETS_DIR="/tmp/mpv-sockets/"

for socket in "${SOCKETS_DIR}"/*; do
    [ -e "${socket}" ] || break
    echo 'set pause yes' | socat - "${socket}";
done

[ -n "$(pgrep "${BROWSER}")" ] && pkill -STOP "${BROWSER}"

"${LOCKER}"

temp="$(mktemp)"

jobs -p > "${temp}"

wait < "${temp}"

pkill -CONT "${BROWSER}"
