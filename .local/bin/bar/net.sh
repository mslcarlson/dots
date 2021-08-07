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

        # scan interface
        iwctl station "${interface}" scan

        # get available networks and known networks
        get_network_info "iwctl station ${interface} get-networks" 'iwctl known-networks list'

        # user can connect, disconnect, or forget network
        # don't care bout access points or other stuff
        show_menu 'Wifi Menu' 'Connect' 'Disconnect' 'Forget'
    }

    connect() {
        # user can choose network to connect to
        network="$(show_menu 'Connect' "${available_network_names}")"

        # if network starts with '> ' it means user is already on that network
        case "${network}" in '> '*) printf 'Already connected to this network\n' && return ;; esac

        # if network is known connect with no passphrase
        if printf '%s\n' "${known_network_info}" | awk -F '|' '{print $1}' | grep -q "\<${network}\>"; then
            iwctl station "${interface}" connect "${network}"
            return
        fi

        # if network is wep, psk, or 8021x get passphrase
        case "$(printf '%s\n' "${available_network_info}" | grep "\<${network}\>" | awk -F '|' '{print $2}')" in
            'wep'|'psk'|'8021x') get_passphrase                       ;;
        # if open just connect without passphrase
            'open') iwctl station "${interface}" connect "${network}" ;;
        esac

        # connect with passphrase
        [ -n "${passphrase}" ] && iwctl --passphrase "${passphrase}" station "${interface}" connect "${network}"
    }

    disconnect() {
        connected_network="$(iwctl station "${interface}" show | grep '\<Connected network\>' | awk '{ $1=""; $2=""; sub("  ", " "); {$1=$1;print} }')"
        if [ -n "${connected_network}" ]; then
            answer="$(show_menu "Disconnect from ${connected_network}?" 'Yes' 'No')"
            case "$(printf '%s\n' "${answer}" | tr '[:upper:]' '[:lower:]')" in
                'yes') iwctl station "${interface}" disconnect ;;
                'no')  return                                  ;;
            esac
        fi
    }

    forget() {
        # if there are known networks
        if [ -n "${known_network_names}" ]; then
            # get network
            network="$(show_menu 'Forget' "${known_network_names}")"

            # get confirmation
            answer="$(show_menu "Forget ${network}?" 'Yes' 'No')"

            # forget if answer is yes
            [ "${answer}" = 'Yes' ] && iwctl known-networks "${network}" forget
        fi
    }

    # get network columns separately
    get_network_column() {
        types='open|wep|psk|8021x'
        printf '%s\n' "${info}" | awk -v var="${1}" -F "\\${types}" '{ print $var }' | sed 's/^[ \t]*//;s/[ \t]*$//'
    }

    get_network_info() {
        if [ "${1}" = "iwctl station ${interface} get-networks" ]; then
            info="$(eval "${1}" | grep '\s' | tail +3 | awk '{ $1 = $1 }; 1' | sed -e 's/\x1b\[[0-9;]*m//g')"

            available_network_names="$(get_network_column '1')"
            available_network_types="$(printf '%s\n' "${info}" | awk '{ for (i=1;i<=NF;i++){ if ($i ~ /open|wep|psk|8021x/) { print $i } } }')"
            available_network_strengths="$(get_network_column '2')"

            i=1
            available_network_info="$(printf '%s\n' "${available_network_names}" | ( while read -r name; do
                type_field="$(printf '%s\n' "${available_network_types}" | sed -n ${i}p)"
                strength_field="$(printf '%s\n' "${available_network_strengths}" | sed -n ${i}p)"

                if [ ${i} -eq 1 ]; then available_network_info="${name}|${type_field}|${strength_field}"
                else available_network_info="${available_network_info}${NEWLINE}${name}|${type_field}|${strength_field}"
                fi

                i=$((i+1))
            done
            printf '%s\n' "${available_network_info}" ))"
        fi

        if [ "${2}" = 'iwctl known-networks list' ]; then
            info="$(eval "${2}" | grep '\s' | tail +3 | awk '{ $1 = $1 }; 1' | sed -e 's/\x1b\[[0-9;]*m//g')"

            known_network_names="$(get_network_column '1')"
            known_network_types="$(printf '%s\n' "${info}" | awk '{ for (i=1;i<=NF;i++){ if ($i ~ /open|wep|psk|8021x/) { print $i } } }')"
            known_network_dates="$(get_network_column '2')"

            i=1
            known_network_info="$(printf '%s\n' "${known_network_names}" | ( while read -r name; do
                type_field="$(printf '%s\n' "${known_network_types}" | sed -n ${i}p)"
                date_field="$(printf '%s\n' "${known_network_dates}" | sed -n ${i}p)"

                if [ ${i} -eq 1 ]; then known_network_info="${name}|${type_field}|${date_field}"
                else known_network_info="${known_network_info}${NEWLINE}${name}|${type_field}|${date_field}"
                fi

                i=$((i+1))
            done
            printf '%s\n' "${known_network_info}" ))"
        fi
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
                # if answer is a function run it else just print it
                cmd="$(printf '%s\n' "${answer}" | tr '[:upper:]' '[:lower:]')"
                if command -v "${cmd}" >/dev/null 2>&1 && [ "${cmd}" != 'yes' ]; then "${cmd}"
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
