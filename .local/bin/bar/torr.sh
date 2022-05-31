#!/bin/sh
#
# torr

ICON=''
TORRS="${XDG_CACHE_HOME:-${HOME}/.cache}/dots/bar/torrs"

add() {
    err && return 1

    # add with transmission-remote, don't care about rpc output
    # actual magnet link or file is ${2}; ${1} is -a flag
    if transmission-remote -a "${2}" >/dev/null; then
        # get added torrent name in nice format
        # most recent torrent will be at bottom of list
        torr="$(transmission-remote -l 2>/dev/null | tail -2 | head -1 | tr -s ' ')"
        torr="${torr%% }"
        torr="${torr## }"
        torr="$(printf '%s\n' "${torr}" | cut -d ' ' -f9- | tr '+' ' ')"

        herbe "Added ${torr}" &
    else
        herbe 'Error adding torrent' &
        return 1
    fi
}

bar() {
    daemon_not_running && [ -f "${TORRS}" ] && printf '%s\n' "${ICON} $(cat "${TORRS}")" && return

    [ -n "${TR_TORRENT_NAME}" ] && herbe "${TR_TORRENT_NAME} downloaded"

    torrs="$(transmission-remote -l 2>/dev/null | head -n -1 | tail -n +2)"

    unfinished="$(printf '%s\n' "${torrs}" | awk '{print $2}' | grep -v '100%' | grep -c '.')"

    printf '%s\n' "${unfinished}" > "${TORRS}"

    printf '%s\n' "${ICON} ${unfinished}"
}

err() {
    if daemon_not_running; then
        herbe 'Torrent daemon is not active' &
        return 0
    else
        return 1
    fi
}

open() {
    err && return 1
    "${TERMINAL}" -c "${TORRENT_CLIENT}" -e "${TORRENT_CLIENT}"
}

rmdone() {
    daemon_not_running && printf '%s\n' 'Torrent daemon is not active' && return 1
    transmission-remote -l 2>/dev/null | awk '$2 == "100%" { system("transmission-remote -t "$1" -r >/dev/null") }'
}

# torrent daemon must be running for program to work
daemon_not_running() {
    tid="$(ps -ef | grep -i '\<transmission-daemon\>' | grep -iv '\<grep\>' | awk '{ printf "%s", $2 }')"

    if [ -n "${tid}" ]; then
        return 1
    else
        return 0
    fi
}

main() {
    [ ${#} -eq 0 ] && bar

    case ${BLOCK_BUTTON} in 1) open ;; esac

    while getopts 'aor' opt; do
        case "${opt}" in
            # add torrent
            # argument should be torrent file or magnet file
            a) add "${@}" ;;
            # open torrent client
            o) open       ;;
            # remove all completed torrents
            r) rmdone     ;;
            *) return     ;;
        esac
    done
}

main "${@}"
