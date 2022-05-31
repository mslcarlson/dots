#!/bin/sh
#
# rss

ICON=''
GET_ICON=''
TMP='/tmp/get-rss'

bar() {
    # is reloading
    [ -f "${TMP}" ] && cat "${TMP}" && return

    # a decent way of finding out if prog is open without pgrep
    # TODO: implement this in other scripts where ps -ef is used
    if ps -ef | grep "${RSS_READER}" | tr -s ' ' | cut -f8- -d ' ' | grep -qx "${RSS_READER}"; then
        printf '%s\n' "${ICON}"
    else
        # print unread articles
        unread="$(newsboat -x print-unread | awk '{print $1}')"
        printf '%s\n' "${ICON} ${unread}"
    fi
}

get_rss() {
    printf '%s\n' "${GET_ICON}" > "${TMP}"
    newsboat -x reload
    # delay to ensure reload icon always shows
    sleep 1
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
