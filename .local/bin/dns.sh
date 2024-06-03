#!/bin/sh
#
# dns

# system copy of /etc/resolv.conf
RESOLV_SYS='/etc/resolv.conf'
# nm's copy of resolv.conf
RESOLV_NM='/var/run/NetworkManager/resolv.conf'

# check to see whether ethernet interface is up
eth_is_up() {
    # show active interfaces via nmcli and grep for the one we want
    nmcli -t -f DEVICE connection show --active | grep "${1}" >/dev/null

    #shellcheck disable=SC2046
    return $(get_interface_status "${?}")
}

get_interface_status() {
    status="${1}"
    # interface is up
    if [ "${status}" = '0' ]; then
        return 0
    # interface is down
    else
        return 1
    fi
}

# get wlan interface name
get_wlan_interface() {
    # loop over interfaces in /sys/class/net
    for interface in '/sys/class/net/'*; do
        # wireless interfaces will have a subfolder called 'wireless'
        # if carrier = 1, then the interface is up
        if [ -d "${interface}/wireless/" ] && [ "$(cat "${interface}/carrier")" = '1' ]; then
            printf '%s\n' "${interface##*/}"
        fi
    done

    return 0
}

# check to see whether wifi is up
wifi_is_up() {
    # get ssid of wlan via iw
    ssid="$(iw dev "${1}" info 2>/dev/null | grep -i '\<ssid\>' | awk '{ print $2 }')"

    # if no ssid, then the wifi is down and /etc/resolv.conf may be blank
    if [ -z "${ssid}" ]; then
        return 1
    else
        return 0
    fi
}

main() {
    # this script requires iwd and nm
    if ! command -v iw >/dev/null && ! command -v nmcli >/dev/null; then
        printf '%s\n' 'iw and NetworkManager are required to run this script.'
        return 1
    fi

    # get name of eth interface
    eth_interface="$(basename '/sys/class/net/eth'*)"
    # get name of wlan interface
    wlan_interface="$(get_wlan_interface)"

    # automatically get nameservers if wifi goes down but ethernet remains
    while :; do
        # if eth interface is up, then check for nameservers
        if eth_is_up "${eth_interface}"; then
            grep 'nameserver' "${RESOLV_SYS}" >/dev/null
            has_dns="${?}"

            # if there are nameservers, then the wifi interface must be up (or the ethernet interface was manually enabled)
            # do nothing
            if [ "${has_dns}" = '0' ]; then
                :
            # if there are no nameservers, then replace /etc/resolv.conf with nm's resolv.conf
            else
                cp "${RESOLV_NM}" "${RESOLV_SYS}"
            fi
        # if eth interface is down, then it could've been disabled manually
        # if wifi is still up, then add the nameserver(s) from dhcpcd's resolv.conf
        else
            # if wifi is up, then check for nameserver(s)
            if wifi_is_up "${wlan_interface}"; then
                grep 'nameserver' "${RESOLV_SYS}" >/dev/null
                has_dns="${?}"

                # if there is a nameserver or if there are nameservers, then do nothing
                if [ "${has_dns}" = '0' ]; then
                    :
                # if there aren't any nameservers, then copy dhcpcd's resolv.conf to /etc/resolv.conf
                else
                    # dhcpcd's resolv.conf contents for the wlan interface should be located here
                    resolv_dhcpcd="/var/run/dhcpcd/hook-state/resolv.conf/${wlan_interface}.dhcp"
                    # if dhcpcd does have a resolv.conf, then proceed
                    if [ -e "${resolv_dhcpcd}" ]; then
                        cp "${resolv_dhcpcd}" "${RESOLV_SYS}"
                    else
                        :
                    fi
                fi
            else
                :
            fi
        fi
        sleep 10
    done

    return 0
}

main "${@}"
