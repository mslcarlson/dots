#!/bin/sh
#
# music

MUSIC_ICON=''
PLAYING_ICON=''
PAUSED_ICON=''

open() { "${TERMINAL}" -c "${MUSIC_PLAYER}" -e "${MUSIC_PLAYER}" ; }

bar() {
    # get current song name
    song="$(mpc -f %title% | head -n 1)"
    # get state of song
    stat="$(mpc -f %title% | sed '2q;d' | awk '{ print $1 }' | tr -d '[:punct:]')"

    # no songs
    [ -z "${stat}" ] && printf '%s\n' "${MUSIC_ICON}"
    # song is playing
    [ "${stat}" = 'playing' ] && printf '%s\n' "${PLAYING_ICON} ${song}"
    # paused
    [ "${stat}" = 'paused' ] && printf '%s\n' "${PAUSED_ICON} ${song}"
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open                                             ;;
        2) mpc -q toggle                                    ;;
        4) mpc -q prev                                      ;;
        5) [ -n "$( mpc -f %title% queue)" ] && mpc -q next ;;
    esac

    while getopts 'o' opt; do
        case "${opt}" in
            # open music player if called with o flag
            o) open ;;
        esac
    done
}

main "${@}"
