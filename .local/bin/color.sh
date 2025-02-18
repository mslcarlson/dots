#!/bin/sh
#
# color

COLOR="${XDG_CACHE_HOME:-${HOME}/.cache/}/dots/color"

# should work with compton too
COMPOSITOR='picom'

# we can make windows mono via shader
SHADER="${XDG_DATA_HOME:-${HOME}/.local/share/}/picom/gray.glsl"

start() {
    # get mode stored in cache
    # 0 means mono
    # 1 means color
    mode=$(cat "${COLOR}")

    # start compositor
    [ "${mode}" -eq 1 ] && ${COMPOSITOR} -b --backend glx \
                        || ${COMPOSITOR} -b --backend glx --window-shader-fg="${SHADER}" 2>/dev/null
}

toggle() {
    # check shader status and thus check mode
    #shellcheck disable=SC2009
    shader_id=$(ps -ef | grep 'window-shader-fg' | grep -iv '\<grep\>' | awk '{ printf "%s ", $2 }')

    # shader enabled, meaning mono
    # ENABLE COLOR
    if [ "${shader_id}" ]; then
        #shellcheck disable=SC2086
        $(kill ${shader_id} && \
        sleep 1             && \
        ${COMPOSITOR} -b --backend glx) || return 1
        mode=1
    # shader disabled, meaning color
    # DISABLE COLOR
    else
        #shellcheck disable=SC2086
        $(kill ${comp_id}                                                        && \
        sleep 1                                                                  && \
        ${COMPOSITOR} -b --backend glx --window-shader-fg="${SHADER}" 2>/dev/null) || return 1
        mode=0
    fi

    # print mode to cache so we remember mode at launch
    printf '%s\n' "${mode}" > "${COLOR}"
}

main() {
    if [ ${#} -eq 0 ]; then
        # get compositor id
        #shellcheck disable=SC2009
        comp_id=$(ps -ef | grep "\<${COMPOSITOR}\>" | grep -iv '\<grep\>' | awk '{ printf "%s ", $2 }')

        # compositor not running, so return
        [ -z "${comp_id}" ] && printf '%s\n' "${COMPOSITOR} is not running" && return 1

        # toggle between mono/color modes
        if toggle; then
            # get mode
            [ "${mode}" -eq 1 ] && msg='Color enabled' || msg='Color disabled'
        else printf '%s\n' 'Toggle failed' && return 1
        fi

        # print notification
        env HERBE_ID=/0 herbe "${msg}" &
    fi

    # flags for profile
    while getopts 's' opt; do
        case "${opt}" in
            # automatically pick mode based on cache
            s) start        ;;
            *) return       ;;
        esac
    done
}

main "${@}"
