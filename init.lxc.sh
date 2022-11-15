#!/bin/bash

echo "##############################"
echo "##### init.lxc.sh script #####"
echo "##############################"

set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/init-modules/declaration.sh

###################################
echo_headline "BOOTSTRAP INIT FOLDER"
if [ ! -d "$INIT_DIR" ]; then
    rsync --mkpath -aPhhv "$(dirname "$(realpath "$BASH_SOURCE")")"/ "$INIT_DIR"
fi

###################################
if type apt >/dev/null 2>&1; then
    echo_headline "INSTALL BASE UBUNTU"
    sudo apt update
    sudo apt upgrade -y
    sudo apt purge -y vim
    sudo apt install -y curl wget fish git git-lfs build-essential fd-find bat fzf python3-pip vim-gtk
    sudo apt autoremove -y
    # sudo apt install -y texlive-latex-extra texlive-science texlive-lang-french texlive-extra-utils latexmk python3-pygments
    # sudo apt install -y default-jdk libswt-gtk-4-java # Required for java gui
    sudo ln -fs "$(which fdfind)" "$USR_LOCAL_BIN"/fd
    sudo ln -fs "$(which batcat)" "$USR_LOCAL_BIN"/bat
fi

read -rp "Nvidia prime ? [y/n, default=y] " prime
if [ "${prime:-n}" = "y" ]; then
    prime_run="prime-run"
    if type "$prime_run" >/dev/null 2>&1; then
        echo_headline "INSTALL BASE UBUNTU"
        cat >"$LOCAL_BIN/$prime_run" <<'EOF'
#!/bin/bash
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
exec "$@"
EOF
        chmod +x "$LOCAL_BIN/$prime_run"
    fi
fi

###################################
echo_headline "INIT .BASHRC"
init_bashrc -nr

###################################
echo_headline "RUN CONFIGURATIONS SCRIPTS"
bash "$INIT_MODULES"/link-configs.sh
git_config

###################################
echo_headline "INSTALL CUSTOM PACKAGES"
bash "$INIT_MODULES"/update-pkgs.sh
