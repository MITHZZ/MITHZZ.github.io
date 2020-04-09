#!/bin/bash
#
# Find out the posts that have been modified and record
# its lastmod information to file '_data/lastmod.yml'
#
# Usage:
#     Call from the '_posts' sibling directory.
#
# v2.2
# https://github.com/cotes2020/jekyll-theme-chirpy
# © 2020 Cotes Chung
# Published under MIT License

set -eu

POST_DIR=_posts
OUTPUT_DIR=_data
OUTPUT_FILE=updates.yml


_init() {
  if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir "$OUTPUT_DIR"
  fi

  if [[ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]]; then
    rm -f "$OUTPUT_DIR/$OUTPUT_FILE"
  fi

  touch "$OUTPUT_DIR/$OUTPUT_FILE"
}


_has_changed() {
  local _log_count=`git log --pretty=%ad $1 | wc -l`

  if [[ $_log_count = "1" ]]; then
    return 1 # false
  else
    return 0 # true
  fi
}


###################################
# Storage the posts' lastmod.
#
# Args:
#     - $1 a numeric index that matchs Jekyll site.posts
#     - $2 filename
#     - $3 filepath
# Output:
#     the file '_data/lastmod.yml'
###################################
_dump() {
  local _lasmod="`git log -1 --pretty=%ad --date=iso $3`"

  echo "-" >> "$OUTPUT_DIR/$OUTPUT_FILE"
  echo "  index: $1" >> "$OUTPUT_DIR/$OUTPUT_FILE"
  echo "  filename: $2" >> "$OUTPUT_DIR/$OUTPUT_FILE"
  echo "  lastmod: $_lasmod" >> "$OUTPUT_DIR/$OUTPUT_FILE"
}


main() {

  _init

  local _index=0
  local _count=0

  for _file in $(ls -r "$POST_DIR")
  do
    _filepath="$POST_DIR/$_file"
    _filename="${_file%.*}" # jekyll cannot read the extension of a file, so omit it.

    if _has_changed "$_filepath"; then
      _dump "$_index" "$_filename" "$_filepath"
      ((_count=_count+1))
    fi

    ((_index=_index+1))
  done

  if [[ $_count > 0 ]]; then
    echo "[INFO] Success to update lastmod for $_count post(s)."
  fi
}


main
