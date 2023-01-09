#!/bin/sh
#
# chat

HOST='127.0.0.1'
# standard IRC port
PORT='6667'
# encrypted connection
SSL='6697'
# the most popular IRC network
NETWORK='irc.libera.chat'
CHANNEL='archlinux'
NICK='RETRACTED'
PASS="${XDG_DATA_HOME:-${HOME}/.local/share/}/kirc/pass.gpg"
LOG="${XDG_DATA_HOME:-${HOME}/.local/share/}/kirc/kirc.log"

log() {
    while :; do
        tail -fn 1 "${1}" | awk "/PRIVMSG #.*${NICK}.*/ {
            system(\"herbe 'kirc - new message!' &\")
            exit
        }"
        printf '%s\n' "$(date +'%a %b %e %H:%M:%S %Y')::kirc - new message!" >> "${1}"
        sleep 1
    done

    return 0
}

# TODO: figure out how to 'daemonize' kirc, maybe implement networks other than libera
main() {
    # test for dependencies
    { command -v socat >/dev/null && command -v kirc >/dev/null; } || { printf '%s\n' 'socat and/or kirc not installed.'; return 1; }

    # connect to network
    while ! socat /dev/null ssl:"${network}":"${SSL}" 2>/dev/null; do
        printf '%s' "Enter IRC network [${NETWORK}]: "
        read -r network
        if [ -z "${network}" ]; then
            network="${NETWORK}"
        else
            printf '%s\n' 'Testing network...'
        fi
    done
    if socat tcp-listen:"${PORT}",reuseaddr,fork,bind="${HOST}" ssl:"${network}":"${SSL}" >/dev/null 2>&1 & pids="${pids-} ${!}"; then
        # get socat pid so we can kill it after
        socatid="${!}"

        printf '%s\n' "Securely connected to ${network} via TLS/SSL."

        # get channel to join
        printf '%s' "Enter channel name without the '#' [archlinux]: "
        read -r channel
        [ -z "${channel}" ] && channel="${CHANNEL}"

        # gen auth token for SASL PLAIN
        pass="$(gpg -dq "${PASS}")"
        SASL="$(python -c "import base64; print(base64.standard_b64encode(b'${NICK}\x00${NICK}\x00${pass}'))")"
        #shellcheck disable=SC2059
        SASL="$(printf '%s\n' "${SASL}" | awk -v FS="(b'|')" '{print $2}')"

        # enable logging
        log "${LOG}" & pids="${pids-} ${!}"

        # launch IRC client
        kirc -s "${HOST}" -a "${SASL}" -c "${channel}" -n "${NICK}" -o "${LOG}"

        # kill pids
        #shellcheck disable=SC2086
        kill -9 ${pids}
    else
        printf '%s\n' 'Unable to connect via TLS/SSL. Is the address or port already in use?'
        return 1
    fi

    return 0
}

main "${@}"
