#!/bin/sh
#
# pass

CREDENTIALS_DIR="${XDG_DATA_HOME:-${HOME}/.local/share/}/pass"
NEWLINE='
'

get_credential() {
    credential="$(printf '%s\n' "${credentials}" | grep "\<${1}\>" | awk -F ':' '{ print $2 }')"
    credential="${credential%\'}"
    credential="${credential#\'}"
}

main() {
    i=0
    for site in "${CREDENTIALS_DIR}"/*.gpg; do
        site="${site%.*}"
        if [ ${i} -eq 0 ]; then sites="${sites}${site##*/}"
        else sites="${sites}${NEWLINE}${site##*/}"
        fi
        i=$((i+1))
    done

    site="$(printf '%s\n' "${sites}" | dmenu -c -l 10)"

    credentials="$(gpg -dq "${CREDENTIALS_DIR}"/"${site}".gpg)"

    credential_types="$(printf '%s\n' "${credentials}" | awk -F ':' '{ print $1 }')"

    squestions="$(printf '%s\n' "${credential_types}" | grep -c 'squestion*')"

    credential_options="$(printf '%s\n' "${credential_types}" | ( while read -r type; do
        case "${type}" in
            'uname')      printf 'Username\n'          ;;
            'pw')         printf 'Password\n'          ;;
            'email')      printf 'Email\n'             ;;
            'squestion'*) i=1
                          while [ ${i} -le ${squestions} ]; do
                              printf '%s\n' "Security Question ${i}"
                              i=$((i+1))
                          done
                          break
                          ;;
        esac
    done
    printf '%s\n' "${credential_options}" ))"

    credential_option="$(printf '%s\n' "${credential_options}" | dmenu -c -l 10 -p 'Credentials')"

    if printf '%s\n' "${credential_option}" | grep -q '\<[0-9]\>'; then num="$(printf '%s\n' "${credential_option}" | awk '{ print $3 }')" ; fi

    case "${credential_option}" in
        'Username')                 get_credential 'uname'         ;;
        'Password')                 get_credential 'pw'            ;;
        'Email')                    get_credential 'email'         ;;
        "Security Question ${num}") get_credential "sanswer${num}" ;;
    esac

    if printf '%s\n' "${credential}" | xclip -selection clipboard; then { herbe "${credential_option} for "${site}" copied to clipboard" & } ; fi
}

main "${@}"
