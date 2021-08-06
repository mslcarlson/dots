#!/bin/sh
#
# net

NEWLINE='
'

net_menu() {
    main_menu() {
        # get first 802.11 capable device from /sys/class/net
        interface="$(for dev in /sys/class/net/*; do
                        [ -e "${dev}/wireless" ] && printf '%s\n' "${dev##*/}"
                    done | head -n 1)"

        # scan interface for available networks
        iwctl station "${interface}" scan

        # user can connect, disconnect, or forget network
        # don't care bout access points or other stuff
        show_menu 'Wifi Menu' 'Connect' 'Disconnect' 'Forget'
    }

    connect() {
        # get networks and their types + signals
        info="$(iwctl station "${interface}" get-networks | grep '\s' | tail +3 | awk '{ $1 = $1 }; 1' | sed -e 's/\x1b\[[0-9;]*m//g')"

        # names
        network_names="$(get_network_info '1')"
        # valid network types are open, wep, psk, 8021x
        network_types="$(printf '%s\n' "${info}" | awk '{ for (i=1;i<=NF;i++){ if ($i ~ /open|wep|psk|8021x/) { print $i } } }')"
        # strength will be 1-4 asterisks
        network_strengths="$(get_network_info '2')"

        # combine info with delimiter b/c wifi names can have spaces which messes with awk
        i=1
        combined_info="$(printf '%s\n' "${network_names}" | ( while read -r name; do
            # get type and strength associated with network
            ntype="$(printf '%s\n' "${network_types}" | sed -n ${i}p)"
            strength="$(printf '%s\n' "${network_strengths}" | sed -n ${i}p)"

            # append network as new line to variable (with newline if not first)
            if [ ${i} -eq 1 ]; then combined_info="${name}|${ntype}|${strength}"
            else combined_info="${combined_info}${NEWLINE}${name}|${ntype}|${strength}"
            fi

            i=$((i+1))
        done
        printf '%s\n' "${combined_info}" ))"

        # user can choose network to connect to
        network="$(show_menu 'Connect' "${network_names}")"

        # if network starts with '> ' it means user is already on that network
        case "${network}" in '> '*) printf 'Already connected to this network\n' && return ;; esac

        # if network is wep, psk, or 8021x get passphrase
        case "$(printf '%s\n' "${combined_info}" | grep "${network}" | awk -F '|' '{print $2}')" in
            'wep'|'psk'|'8021x') get_passphrase ;;
        # if open just connect without passphrase
            'open') iwctl station "${interface}" connect "${network}"
        esac

        # connect with passphrase
        [ -n "${passphrase}" ] && iwctl --passphrase "${passphrase}" station "${interface}" connect "${network}"
    }

    disconnect() {
        :
    }

    forget() {
        :
    }

    # get network columns separately
    get_network_info() {
        types='open|wep|psk|8021x'
        printf '%s\n' "${info}" | awk -v var="${1}" -F "\\${types}" '{ print $var }' | sed 's/^[ \t]*//;s/[ \t]*$//'
    }

    # hide input with dmenu -P flag
    get_passphrase() { passphrase="$(dmenu -c -p 'Passphrase:' -P)" ; }

    show_menu() {
        # first arg is prompt
        prompt="${1}"
        shift

        # remaining opts are options
        options="$(for option in "${@}"; do
                    printf '%s\n' "${option}"
                done)"

        # print using dmenu
        answer="$(printf '%s\n' "${options}" | dmenu -c -l 10 -p "${prompt}")"

        # get user's answer
        printf '%s\n' "${options}" | while read -r line; do
            if [ "${line}" = "${answer}" ]; then
                # if answer is a command run it else just print it
                cmd="$(printf '%s\n' "${answer}" | tr '[:upper:]' '[:lower:]')"
                if command -v "${cmd}" 2>/dev/null; then "${cmd}"
                else printf '%s\n' "${answer}"
                fi
                break
            fi
        done
    }

    main_menu
}


main() {
    net_menu
}

main "${@}"
