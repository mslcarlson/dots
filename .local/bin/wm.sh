#!/bin/sh
#
# wm

main() { while :; do "${WM}" >/dev/null 2>&1; done ; }

main "${@}"
