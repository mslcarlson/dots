#!/bin/sh
#
# mail

ICON=''
GET_ICON=''
ISYNCRC="${XDG_CONFIG_HOME:-${HOME}/.config/}/isync/isyncrc"
# both personal and school mail
PERSONAL_MAIL_DIR="${MAIL_DIR}/matt/INBOX/new/"
SCHOOL_MAIL_DIR="${MAIL_DIR}/algomau/INBOX/new/"
TMP='/tmp/get-mail'

# count mail files in dir
count_mail() { [ -e "${1}" ] && printf '%s\n' "${#}" || printf '%s\n' 0 ; }

# use isync to get mail from server
get_mail() {
    printf '%s\n' "${GET_ICON}" > "${TMP}"
    mbsync -c "${ISYNCRC}" -aq
    rm -f "${TMP}"
}

open() { "${TERMINAL}" -c "${TERMINAL}" -e "${MAIL_CLIENT}" && { get_mail & } ; }

bar() {
    # count personal and school mail then sum together
    personal_mail_count=$(count_mail "${PERSONAL_MAIL_DIR}"/*)
    school_mail_count=$(count_mail "${SCHOOL_MAIL_DIR}"/*)
    total_mail_count=$((personal_mail_count + school_mail_count))

    # if getting mail show get icon
    [ -f "${TMP}" ] && printf '%s\n' "${GET_ICON}" && return

    # if mail open show just mail icon
    if ps -ef | grep -i "\<${MAIL_CLIENT}\>" | grep -iqv '\<grep\>'; then printf '%s\n' "${ICON}"
    # otherwise print both icon and count
    else printf '%s\n' "${ICON} ${total_mail_count}"
    fi
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open     ;;
        2) get_mail ;;
    esac

    while getopts 'go' opt; do
        case "${opt}" in
            # get mail if called with g flag
            g) get_mail ;;
            # open mail if o flag used
            o) open     ;;
            *) return   ;;
        esac
    done
}

main "${@}"
