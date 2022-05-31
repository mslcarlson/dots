#!/bin/sh
#
# hosts

HOSTS_DIR="${HOME}/.local/share/"

enable() { mv "${HOSTS_DIR}hosts.bak" "${HOSTS_DIR}hosts" && env HERBE_ID=/0 herbe 'Hosts enabled' & }

disable() { mv "${HOSTS_DIR}hosts" "${HOSTS_DIR}hosts.bak" && env HERBE_ID=/0 herbe 'Hosts disabled' & }

main() {
    # in each of the following cases we want to sleep to prevent xcb unknown sequence number error

    # disable by moving hosts to xdg share directory
    [ -f "${HOSTS_DIR}/hosts" ]  && disable && sleep 1 && return 0

    # enable by moving hosts to /etc/
    # shellcheck disable=SC3044
    [ -f "${HOSTS_DIR}/hosts.bak" ] && enable  && sleep 1 && return 0
}

main "${@}"
