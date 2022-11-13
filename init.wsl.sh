#!/bin/bash

echo "##############################"
echo "##### init.wsl.sh script #####"
echo "##############################"

###################################
if type sudo >/dev/null 2>&1; then
    echo "<---------- DISABLE ROOT PASSWORD ---------->"
    sudo passwd -l root
    # sudo usermod --expiredate 1 root # sometimes Arch updates need root account
    sudo sed -i '/#PermitRootLogin/a PermitRootLogin no' /etc/ssh/sshd_config || :
    echo "Don't forget to restart SSH daemon"
    sleep 10
else
    echo "ERROR: sudo not found on system"
    exit 1
fi

###################################
set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/init-modules/declaration.sh

###################################
echo_headline "BOOTSTRAP INIT FOLDER"
if [ ! -d "$INIT_DIR" ]; then
    mkdir -p "$INIT_DIR"
    cp -R "$(dirname "$(realpath "$BASH_SOURCE")")"/. "$INIT_DIR"/
fi

###################################
echo_headline "INSTALL PACMAN PACKAGES"
sudo pacman -Syyu --needed base-devel github-cli fish \
    python-pip unrar git git-lfs bash-language-server zellij \
    fzf fd bat tree

###################################
echo_headline "INSTALL AURs"
git clone https://aur.archlinux.org/paru.git
(
    cd paru
    makepkg -si
)
rm -rf paru
sleep 1

###################################
echo_headline "INIT .BASHRC"
init_bashrc

###################################
echo_headline "RUN CONFIGURATIONS SCRIPTS"
add_to_configs
bash "$INIT_MODULES"/link-configs.sh
git_config

###################################
echo_headline "INSTALL CUSTOM PACKAGES"
bash "$INIT_MODULES"/update-pkgs.sh

read -rp "\n<---------- THE END, PRESS ANY KEY TO REBOOT NOW ---------->\n" r
reboot
