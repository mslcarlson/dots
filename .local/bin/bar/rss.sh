#!/bin/sh
#
# rss

ICON=''
GET_ICON=''
TMP='/tmp/get-rss'
RSS="${XDG_CACHE_HOME:-${HOME}/.cache/}/dots/bar/rss"

bar() {
    # is reloading
    [ -f "${TMP}" ] && cat "${TMP}" && exit 0

    # a decent way of finding out if prog is open without pgrep
    # TODO: implement this in other scripts where ps -ef is used
    if ps -ef | grep "${RSS_READER}" | tr -s ' ' | cut -f8- -d ' ' | grep -qx "${RSS_READER}"; then
        printf '%s\n' "${ICON}"
    else
        # print cache if newsboat is reloading
        newsboat -x print-unread >/dev/null
        [ "${?}" -eq 1 ] && printf '%s\n' "${ICON} $(grep '^[0-9][0-9]*$' "${RSS}")" && exit 0

        # print unread articles
        unread="$(newsboat -x print-unread | awk '{print $1}')"
        printf '%s\n' "${unread}" > "${RSS}"
        printf '%s\n' "${ICON} ${unread}"
    fi
}

get_rss() {
    printf '%s\n' "${GET_ICON}" > "${TMP}"
    newsboat -x reload >/dev/null
    rm -f "${TMP}"
}

open() { "${TERMINAL}" -c "${RSS_READER}" -e "${RSS_READER}" ; }

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open    ;;
        2) get_rss ;;
    esac

    while getopts 'go' opt; do
        case "${opt}" in
            # get rss if called with g flag
            g) get_rss ;;
            # open rss if o flag used
            o) open    ;;
            *) return  ;;
        esac
    done
}

main "${@}"
