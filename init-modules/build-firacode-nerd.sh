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
    sudo docker run --rm -v "$PWD/distr/ttf/Fira Code":/in -v "$PWD"/distr/ttf-patched:/out nerdfonts/patcher -c || :
    sudo docker run --rm -v "$PWD/distr/ttf/Fira Code":/in -v "$PWD"/distr/ttf-patched:/out nerdfonts/patcher -cs || :
    sudo chown $(whoami):$(whoami) distr/ttf-patched/
    mkdir NerdFonts
    mv distr/ttf-patched/ NerdFonts/FiraCode
    mv NerdFonts/ "$HOME"/dev-sync/
fi
