#!/bin/sh
#
# thumb

main() {
    youtube-dl -i --add-metadata                                                                                                                       \
    -f bestaudio/best -x                                                                                                                               \
    --embed-thumbnail                                                                                                                                  \
    --convert-thumbnails png                                                                                                                           \
    --exec-before-download "ffmpeg -i %(thumbnails.-1.filepath)q -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\" _%(thumbnails.-1.filepath)q" \
    --exec-before-download "rm %(thumbnails.-1.filepath)q"                                                                                             \
    --exec-before-download "mv _%(thumbnails.-1.filepath)q %(thumbnails.-1.filepath)q"                                                                 \
    -o "%(playlist_index)s-%(title)s.%(ext)s"                                                                                                          \
    -k                                                                                                                                                 \
    "${@}"
}

main "${@}"
