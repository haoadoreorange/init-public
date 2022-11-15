#!/bin/bash

echo "##############################"
echo "# build-firacode-nerd script #"
echo "##############################"

set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/declaration.sh

###################################
ALREADY_UTD="Already up to date."
msg=''

headline="FIRA CODE NERD"
fira_code="$HIDDEN_HOME"/FiraCode
if [ -d "$fira_code" ]; then
    echo_headline "UPDATE $headline"
    cd "$fira_code"
    msg="$(git pull)"
    echo "$msg"
else
    echo_headline "INSTALL $headline"
    git clone https://github.com/tonsky/FiraCode.git "$fira_code"
    cd "$fira_code"
fi
if [ "${1-}" = "-f" ] || [ "$msg" != "$ALREADY_UTD" ]; then
    sudo docker run --rm -v "$PWD":/opt tonsky/firacode:latest ./script/build.sh -f "cv01,cv04,onum,ss04,ss03,cv15,cv30,ss08"
    ttf_patched="distr/ttf-patched"
    sudo docker run --rm -v "$PWD/distr/ttf/Fira Code":/in -v "$PWD/$ttf_patched":/out nerdfonts/patcher -c || :
    sudo docker run --rm -v "$PWD/distr/ttf/Fira Code":/in -v "$PWD/$ttf_patched":/out nerdfonts/patcher -cs || :
    sudo chown $(whoami):$(whoami) "$ttf_patched"/
    rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$ttf_patched"/ "$HOME"/dev-sync/NerdFonts/FiraCode
    exit 1
fi
exit 0
