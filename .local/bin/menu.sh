#!/bin/sh
#
# menu

main() {
	xmenu << EOF | sh &
Applications
	IMG:./icons/web.png	Web Browser	${BROWSER}
	IMG:./icons/gimp.png	Image editor	gimp

Terminal (xterm)	xterm
Terminal (urxvt)	urxvt
Terminal (st)		st

Shutdown		poweroff
Reboot			reboot
EOF
}

main "${@}"
