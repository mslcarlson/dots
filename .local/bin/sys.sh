#!/bin/sh
#
# sys

CMDS="\
 Lock     lock.sh
 Shutdown doas shutdown -h now
 Restart  doas shutdown -r now
"

lines=$(printf '%s' "${CMDS}" | grep -c '^')

choice="$(printf '%s' "${CMDS}" | cut -d ' ' -f 1-2 | dmenu -c -i -l "${lines}")" || exit 1

cmd="$(printf '%s\n' "${CMDS}" | grep "^${choice}[\s]*" | awk '{ $1=""; $2=""; print }' | sed 's/^[[:space:]]*//g')"

${cmd}
