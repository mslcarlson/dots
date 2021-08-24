#!/bin/sh
#
# net

ERROR_ICON=''
ETH_ICON=''
WIFI_HIGH_ICON=''
WIFI_MED_ICON=''
WIFI_LOW_ICON=''
WIFI_NO_ICON=''

get_interface() {
    # get path to interface
    interface="$(for dev in /sys/class/net/*; do
                     case "${1}" in
                         # wifi will have a wireless/ dir
                         'wifi') [ -d "${dev}/wireless/" ] && [ "$(cat "${dev}/carrier")" -eq 1 ] && printf '%s\n' "${dev}" ;;
                         'eth') [ -d "${dev}/device/" ] && [ ! -d "${dev}/wireless/" ] && [ "$(cat "${dev}/carrier")" -eq 1 ] && printf '%s\n' "${dev}" ;;
                     esac
              done | head -n 1)"
    # isolate interface name
    interface="${interface##*/}"
}

get_local_ip() { local_ip="$(ip a | grep -i "\<${1}\>" | awk '{ for (i = 1; i <= NF; i++) { if ($i ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]*/) { print $i } } }')" ; }

get_ip_addresses() {
    get_interface 'wifi' && get_local_ip "${interface}"
    local_wifi_ip="${local_ip:-N/A}"

    get_interface 'eth' && get_local_ip "${interface}"
    local_eth_ip="${local_ip:-N/A}"

    public_ip="$(curl ifconfig.me/ip)"
    public_ip="${public_ip:-N/A}"
}

get_wifi() {
    get_interface 'wifi'

    # get ssid using iw
    ssid="$(iw dev "${interface}" info | grep -i '\<ssid\>' | awk '{ print $2 }')"

    # no ssid means no wifi
    [ -z "${ssid}" ] && return 1

    # Get wifi strength
    get_wifi_strength

    # one, two, or three bars depending on strength
    case "${wifi_strength}" in
      3[0-9]|4[0-9]|50)     WIFI_ICON="${WIFI_HIGH_ICON}" ;;
      5[1-9]|6[0-9]|7[0-9]) WIFI_ICON="${WIFI_MED_ICON}"  ;;
      8[0-9])               WIFI_ICON="${WIFI_LOW_ICON}"  ;;
      90)                   WIFI_ICON="${WIFI_NO_ICON}"   ;;
    esac

    wifi="${WIFI_ICON} ${ssid}"
}

get_eth() {
    get_interface 'eth'

    # eth unplugged or not working
    [ -z "${interface}" ] && unset ETH_ICON

    eth="${ETH_ICON}"
}

# measured in |dBm|
get_wifi_strength() { [ -e '/proc/net/wireless' ] && wifi_strength=$(grep -i "\<${interface}\>" '/proc/net/wireless' | awk '{ print $4 }' | sed 's/[^0-9]*//g') ; }

bar() {
    get_wifi

    get_eth

    # no wifi or eth and print error
    [ -z "${wifi}" ] && [ -z "${eth}" ] && printf '%s\n' "${ERROR_ICON}" && return 1

    # space needed between wifi and eth if eth is available
    # no eth but wifi
    if [ -z "${eth}" ]; then printf '%s\n' "${wifi}"
    # no wifi but eth
    elif [ -z "${wifi}" ]; then  printf '%s\n' "${eth}"
    # both wifi and eth
    else printf '%s\n' "${wifi} ${eth}"
    fi
}

open() { iwd-dmenu ; }

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open             ;;
        3) get_ip_addresses
           herbe "$(printf '%s\n%s\n%s' "Wifi IP: ${local_wifi_ip}" "Eth IP: ${local_eth_ip}" "Public IP: ${public_ip}")"
           ;;
    esac

    while getopts 'o' opt; do
        case "${opt}" in
            # open if o flag used
            o) open   ;;
            *) return ;;
        esac
    done
}

main "${@}"
