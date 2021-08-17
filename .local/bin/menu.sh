#!/bin/sh
#
# menu

main() {
	xmenu << EOF | sh &
 Programs
	 Web Browser	${BROWSER}
	 Image editor	gimp-2.99
	 Text Editor	${TERMINAL} -c ${TERMINAL} -e ${EDITOR}

 Terminal	${TERMINAL}

 Lock		lock.sh
 Shutdown	doas shutdown -h now
 Restart	doas shutdown -r now
EOF
}

main "${@}"
