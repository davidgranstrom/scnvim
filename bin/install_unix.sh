#!/bin/sh

plugin_dir="$(pwd)"
dest_dir="$1"

# if destination is a symbolic link (old install instructions)
if [ -L "$dest_dir" ]; then
  echo "$dest_dir" already exists! Delete it and run this script again.
fi

mkdir -p "$dest_dir"
[ ! -e "$dest_dir/scnvim" ] && ln -s "$plugin_dir/sc" "$dest_dir/scnvim"
