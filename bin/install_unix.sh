#!/bin/sh

plugin_dir="$(pwd)"
dest_dir="$1"

# if destination is a symbolic link (old install instructions)
if [ -L "$dest_dir" ]; then
  echo "$dest_dir" already exists! Delete it and run this script again.
  exit 1
fi

mkdir -p "$dest_dir"
if [ ! -e "$dest_dir/scnvim" ]; then
  ln -s "$plugin_dir/sc" "$dest_dir/scnvim"
fi

exit 0
