#!/bin/bash

echo "##############################"
echo "#### link-configs script #####"
echo "##############################"

set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/declaration.sh

ASSETS="$INIT_DIR"/assets

echo_headline 'Link ~/.config'
mkdir -p "$HOME_CONFIG"
cp -Rs --remove-destination "$ASSETS"/config/* "$HOME_CONFIG"/

echo_headline 'Link .vimrc'
ln -fs "$ASSETS"/vimrc "$HOME"/.vimrc

echo_headline 'Link .prettierrc.js'
ln -fs "$ASSETS"/prettierrc.js "$HOME"/.prettierrc.js

echo_headline 'Link .sig.profile'
ln -fs "$ASSETS"/sig.profile "$HOME"/.sig.profile

read -rp "Link ~/.ssh ? [y/n, default=n] " link_ssh
if [ "${link_ssh:-n}" = "y" ]; then
    echo_headline 'Link ~/.ssh'
    mkdir -p "$HOME"/.ssh
    cp -s --remove-destination "$ASSETS"/ssh/* "$HOME"/.ssh/
    read -rp "Path of dir of private keys to copy to .ssh, otherwise enter to skip" keys
    if [ -d "${keys-}" ]; then
        cp "$keys"/* "$HOME"/.ssh/
        for file in "$HOME"/.ssh/*; do
            whole_name="$(basename "$file")"
            filename="${whole_name%.*}"
            extension="${whole_name##*.}"
            # If there's a .pub then we own the private key
            # caveat: this exclude pub.pub, but no key should
            # be named like that anyway
            if [ "$filename" != "$extension" ] && [ "$extension" = "pub" ]; then
                chmod 400 "$HOME"/.ssh/"$filename"
            fi
        done
    fi
fi

echo_headline 'Populate executable'
bash "$INIT_BIN"/symlink-bins.sh
mkdir -p "$LOCAL_BIN"

ln -fs "$INIT_BIN"/update-pkgs "$LOCAL_BIN"/
ln -fs "$INIT_BIN"/git-sig "$LOCAL_BIN"/
if ! type update-grub >/dev/null 2>&1; then
    ln -fs "$INIT_BIN"/update-grub.sh "$LOCAL_BIN"/update-grub
fi
