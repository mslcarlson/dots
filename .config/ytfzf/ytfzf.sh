#!/bin/sh
#
# ytfzf.sh

# env vars
YTFZF_CUR=1
YTFZF_ENABLE_FZF_DEFAULT_OPTS=1
YTFZF_HIST=0
YTFZF_NOTI=0

# opt vars
enable_search_hist_menu=0
show_thumbnails=1
search_again=1
preview_side="right"
sort_videos_data=1
enable_search_hist=0
allow_empty_search_hist=0

# fzf default opts
FZF_DEFAULT_OPTS="--color fg:7,preview-fg:2,hl:2,fg+:0,bg+:2,gutter:2,hl+:7,info:2,border:2,prompt:2,pointer:2,marker:2,spinner:2,header:2"
