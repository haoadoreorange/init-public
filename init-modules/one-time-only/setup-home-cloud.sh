#!/bin/bash
set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/../declaration.sh

# Delete home folders and replace it symlink to cloud synced folders
home_cloud="$HIDDEN_HOME"/OneDrive/"$(whoami)"/home
for dir in Desktop Documents Pictures; do
    ldir=$(echo "$dir" | tr '[:upper:]' '[:lower:]')
    mkdir -p "$home_cloud/$ldir"
    if [ ! -L "$HOME/$dir" ] && [ -d "$HOME/$dir" ]; then
        cp -R "$HOME/$dir"/. "$home_cloud/$ldir"/
    fi
    ln_Tfs_dir -d "$home_cloud/$ldir" "$HOME/$dir"
done
ln_Tfs_dir "$HIDDEN_HOME"/OneDrive/"$(whoami)" "$HOME"/OneDrive
ln_Tfs_dir "$HIDDEN_HOME"/Dropbox "$HOME"/Dropbox
