#!/bin/sh
#
# pkgs

ICON=''
UPGRADE_ICON=''
UPGRADE_TMP='/tmp/upgrade-pkgs'
AUR_HELPER='paru'
PKGS="${XDG_CACHE_HOME:-${HOME}/.cache}/bar/pkgs"
GET_TMP='/tmp/get-pkgs'
GET_ICON=''

get_os() {
    command -v pacman >/dev/null                          && os='arch'
    { command -v apt || command -v apt-get ; } >/dev/null && os='debian'
    command -v emerge >/dev/null                          && os='gentoo'
    command -v xbps-install >/dev/null                    && os='void'
}

upgrade_pkgs() {
    trap 'rm -f ${UPGRADE_TMP}; exit 1' INT TERM
    trap exit 1

    upgrade_arch_pkgs() {
        upgrade_repo_pkgs() {
            while :; do
                get_pkgs

                case "${1}" in
                    'pacman') repo_type='Official'
                              available_upgrades=$(printf '%s' "${pacman_pkgs}" | grep -c '^')
                              cmd='pacman'
                              ;;
                    'aur')    repo_type='AUR'
                              available_upgrades=$(printf '%s' "${aur_pkgs}" | grep -c '^')
                              cmd="${AUR_HELPER} -a"
                              ;;
                    *)        return 1 ;;
                esac

                if [ "${available_upgrades}" -eq 0 ]; then
                    [ "${repo_type}" = 'Official' ] && repo_type="$(printf '%s\n' "${repo_type}" | tr '[:upper:]' '[:lower:]')"
                    printf '%s\n' "No ${repo_type} packages available for upgrade at the moment. Press any key to continue."
                    read -r input
                    return
                else
                    if ! doas ${cmd} -Syu; then
                        printf '%s\n' "${repo_type} packages failed to upgrade. Retry? [Y/n] "
                        read -r input
                        input="$(printf '%s\n' "${input}" | tr '[:upper:]' '[:lower:]')"
                        if [ "${input}" = 'y' ]; then continue
                        else return 1
                        fi
                    else return
                    fi
                fi
            done
        }

        upgrade_repo_pkgs 'pacman'
        upgrade_repo_pkgs 'aur'
    }

    touch "${UPGRADE_TMP}"

    get_os

    case "${os}" in 'arch') upgrade_arch_pkgs ;; esac

    rm -f "${UPGRADE_TMP}"
}

get_pkgs() {
    touch "${GET_TMP}"

    get_os

    case "${os}" in
        'arch') pacman_pkgs="$(pacman -Qu 2>/dev/null)"
                if command -v "${AUR_HELPER}" >/dev/null; then
                    aur_pkgs="$("${AUR_HELPER}" -Qum --devel 2>/dev/null)"
                fi
                pkgs="$(printf '%s\n%s' "${pacman_pkgs}" "${aur_pkgs}")"
                ;;
    esac

    if [ -f "${PKGS}" ]; then
        printf '%s' "${pkgs}" > "${PKGS}"
    else touch "${PKGS}"
    fi

    rm -f "${GET_TMP}"
}

bar() {
    [ -f "${PKGS}" ] && pkgs=$(grep -c '^' < "${PKGS}")

    if [ -f "${UPGRADE_TMP}" ]; then printf '%s\n' "${UPGRADE_ICON}"
    elif [ -f "${GET_TMP}" ]; then printf '%s\n' "${GET_ICON}"
    else printf '%s\n' "${ICON} ${pkgs}"
    fi
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in esac

    while getopts 'gu' opt; do
        case "${opt}" in
            # get upgradable pkgs
            g) get_pkgs     ;;
            # upgrade if called with u flag
            u) upgrade_pkgs ;;
            *) return       ;;
        esac
    done
}

main "${@}"
