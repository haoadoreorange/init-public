#!/bin/bash

echo "##############################"
echo "##### update-pkgs script #####"
echo "##############################"

set -euo pipefail
. "$(dirname "$(realpath "$BASH_SOURCE")")"/declaration.sh
. "$CUSTOM_BASHRC"

###################################
echo_headline "INSTALL/UPDATE TRASH-CLI"
pip install --upgrade trash-cli

###################################
echo_headline "INSTALL/UPDATE STARSHIP"
FORCE=1 sh -c "$(curl -fsSL https://starship.rs/install.sh)"

###################################
echo_headline "INSTALL/UPDATE GIT HOOKS"
curl -L https://raw.githubusercontent.com/haoadoreorange/git-helpers/main/install.sh | sh -s "$HIDDEN_HOME"/git-helpers || :

###################################
if type lxc >/dev/null 2>&1; then
    echo_headline "INSTALL/UPDATE DEVEN"
    curl -L https://raw.githubusercontent.com/haoadoreorange/deven/main/install.sh | sh -s "$HIDDEN_HOME"/deven || :
fi

###################################
echo_headline "INSTALL/UPDATE NAUTILUS-PYTHON-SUBMENUS"
curl -L https://raw.githubusercontent.com/haoadoreorange/nautilus-python-submenus/main/install.sh |
    sh -s "$HIDDEN_HOME"/nautilus-python-submenus || :

###################################
if [ -n "${BASH_OO-}" ]; then
    headline="BASH OO FRAMEWORK"
    bashoo="$(dirname "$BASH_OO")"
    if [ -d "$BASH_OO" ]; then
        echo_headline "UPDATE $headline"
        cd "$bashoo"
        git pull
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/niieani/bash-oo-framework.git "$bashoo"
    fi
fi

###################################
#git clone https://github.com/babyadoresorange/dropboxignore.git
#cd dropboxignore/
#sudo make install
#cd ../

###################################
ALREADY_UTD="Already up to date."
msg=''

# <---------- FISH PLUGINS ---------->
################################### <---------- BEGIN ----------> ##################################
if type fish >/dev/null 2>&1; then
    mkdir -p "$HOME_CONFIG"/fish

    ###################################
    headline="FZF.FISH"
    fzf_fish="$HIDDEN_HOME"/fzf.fish
    if [ -d "$fzf_fish" ]; then
        echo_headline "UPDATE $headline"
        cd "$fzf_fish"
        msg="$(git pull)"
        echo "$msg"
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/PatrickF1/fzf.fish.git "$fzf_fish"
    fi
    if [ "${1-}" = "-f" ]; then
        cp -Rs --remove-destination "$fzf_fish"/{completions,conf.d,functions} "$HOME_CONFIG"/fish/
    elif [ "$msg" != "$ALREADY_UTD" ]; then
        cp -Rs "$fzf_fish"/{completions,conf.d,functions} "$HOME_CONFIG"/fish/ || :
    fi
    msg=''

    ###################################
    headline="COLORMAN"
    colorman="$HIDDEN_HOME"/colorman
    if [ -d "$colorman" ]; then
        echo_headline "UPDATE $headline"
        cd "$colorman"
        msg="$(git pull)"
        echo "$msg"
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/spacekookie/omf-color-manual.git "$colorman"
    fi
    if [ "${1-}" = "-f" ]; then
        ln -fs "$colorman"/init.fish "$HOME_CONFIG"/fish/colorman.fish
    elif [ "$msg" != "$ALREADY_UTD" ]; then
        ln -s "$colorman"/init.fish "$HOME_CONFIG"/fish/colorman.fish || :
    fi
    msg=''

fi
################################### <---------- END ----------> ##################################

# <---------- GNOME THEMES & ICONS ---------->
################################### <---------- BEGIN ----------> ##################################
if [ "${XDG_SESSION_DESKTOP-}" = "gnome" ]; then

    ###################################
    headline="JUNO THEME"
    dir_name="Juno-mirage"
    juno_mirage="$HIDDEN_HOME/$dir_name"
    if [ -d "$juno_mirage" ]; then
        echo_headline "UPDATE $headline"
        cd "$juno_mirage"
        msg="$(git pull)"
        echo "$msg"
    else
        echo_headline "INSTALL $headline"
        git clone -b mirage https://github.com/EliverLara/Juno.git "$juno_mirage"
    fi
    if [ "${1-}" = "-f" ] || [ "$msg" != "$ALREADY_UTD" ]; then
        rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$juno_mirage"/ "$HOME"/.themes/"$dir_name"
    fi
    msg=''

    ###################################
    # TODO: check if kora-green is included in repo https://github.com/bikass/kora/issues/107
    # headline="KORA ICONS"
    # dir_name="kora-green"
    # kora="$HIDDEN_HOME"/kora
    # if [ -d "$kora" ]; then
    #     echo_headline "UPDATE $headline"
    #     cd "$kora"
    #     msg="$(git pull)"
    #     echo "$msg"
    # else
    #     echo_headline "INSTALL $headline"
    #     git clone https://github.com/bikass/kora.git "$kora"
    # fi
    # if [ "${1-}" = "-f" ] || [ "$msg" != "$ALREADY_UTD" ]; then
    #     rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$kora/$dir_name"/ "$HOME"/.icons/"$dir_name"
    #     gtk-update-icon-cache -f "$kora"/kora-green
    # fi
    # msg=''

    ###################################
    headline="NORDZY CURSORS"
    dir_name="Nordzy-cursors-white"
    nordzy="$HIDDEN_HOME"/Nordzy-cursors
    if [ -d "$nordzy" ]; then
        echo_headline "UPDATE $headline"
        cd "$nordzy"
        msg="$(git pull)"
        echo "$msg"
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/alvatip/Nordzy-cursors.git "$nordzy"
    fi
    if [ "${1-}" = "-f" ] || [ "$msg" != "$ALREADY_UTD" ]; then
        rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$nordzy/$dir_name"/ "$HOME"/.icons/"$dir_name"
        gtk-update-icon-cache -f "$nordzy"/Nordzy-cursors-white
    fi
    msg=''

    thc="libadwaita-theme-changer"
    git clone https://github.com/odziom91/libadwaita-theme-changer.git "$thc"
    python "$thc"/libadwaita-tc.py --reset
    python "$thc"/libadwaita-tc.py
    rm -rf "$thc"

fi
################################### <---------- END ----------> ##################################

###################################
if [ "${FIRA_CODE-}" = "true" ]; then
    if type docker >/dev/null 2>&1; then
        bash "$INIT_MODULES"/build-firacode-nerd.sh
        fira_build=true
    else
        if type lxc >/dev/null 2>&1 && sudo lxc exec dev -- bash -c "type docker >/dev/null 2>&1" &&
            sudo lxc exec dev -- [ -d /home/ubuntu ]; then
            sudo lxc exec dev -- bash "${INIT_MODULES/$HOME/\/home\/ubuntu}"/build-firacode-nerd.sh
            fira_build=true
        else
            echo -e "${RED}ERROR: Cannot find docker, cannot build Fira Code Nerd${NC}"
        fi
    fi
    if [ "${fira_build-}" = "true" ]; then
        echo_headline "Build Fira Code Nerd successfully"
        dir_name="NerdFonts"
        build_dir="$HOME"/dev-sync/"$dir_name"
        if [ -d "$build_dir" ]; then
            rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$build_dir"/ "$HOME"/.fonts/"$dir_name"
            fc-cache -f -v # Update font cache
        else
            echo -e "${RED}ERROR: Cannot find built fonts, cannot install Fira Code Nerd${NC}"
        fi
    fi
fi

################################### <---------- BEGIN ----------> ##################################
if [ "${FIREFOX_CUSTOM-}" = "true" ]; then

    ###################################
    # Ask Firefox profile path if not found
    if [ -z "${FIREFOX_PROFILE-}" ]; then
        while [ ! -d "${FIREFOX_PROFILE-}" ]; do
            read -rp "Firefox profile dir path: " FIREFOX_PROFILE
        done
        FIREFOX_PROFILE="$(realpath "$FIREFOX_PROFILE")"
        add_to_bashrc "FIREFOX_PROFILE=\"$(echo "$FIREFOX_PROFILE" | sed "s|$HOME|\$HOME|g" | sed "s|$USER|\$(whoami)|g")\""
    fi

    ###################################
    # Check if should add cronie auto backup
    if type crontab >/dev/null 2>&1; then
        comment_prefix="Firefox auto backup profile"
        comment="$comment_prefix $(echo "$FIREFOX_PROFILE" | sed "s|$HOME|\$HOME|g" | sed "s|$USER|\$(whoami)|g")"
        crontab_content="$(crontab -l 2>/dev/null || :)"
        # $crontab_content not contains $comment
        if [ "$crontab_content" = "${crontab_content/\# $comment/}" ]; then
            echo_headline "CONFIG CRONIE FIREFOX AUTO BACKUP PROFILE"
            {
                echo "$crontab_content" | sed -e "/# $comment_prefix/d"
                {
                    cat <<EOF
@daily rsync -aPhhv --delete "$FIREFOX_PROFILE"/ "$APPS_ENCRYPTED_DATA"/firefox # $comment
EOF
                } | sed "s|$HOME|\$HOME|g" | sed "s|$USER|\$(whoami)|g"
            } | crontab -
        fi
    fi

    ###################################
    headline="FIREFOX CSS FIX"
    fffix="$HIDDEN_HOME"/firefox-css-fix
    if [ -d "$fffix" ]; then
        echo_headline "UPDATE $headline"
        cd "$fffix"
        msg="$(git pull)"
        echo "$msg"
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/black7375/Firefox-UI-Fix.git "$fffix"
    fi
    if [ "${1-}" = "-f" ] || [ "$msg" != "$ALREADY_UTD" ]; then
        rsync --mkpath -aPhhv --delete --exclude '*.git' --cvs-exclude "$fffix"/ "$FIREFOX_PROFILE"/chrome
        cp "$fffix"/user.js "$FIREFOX_PROFILE"/

        ###################################
        echo_headline "INSTALL FIREFOX PERSONAL CUSTOM"
        custom="$INIT_DIR"/assets/firefox-custom
        {
            echo
            cat "$custom"/userChrome.css
        } >>"$FIREFOX_PROFILE"/chrome/userChrome.css
        {
            echo
            cat "$custom"/user.js
        } >>"$FIREFOX_PROFILE"/user.js
    fi
    msg=''
fi
################################### <---------- END ----------> ##################################

###################################
# if [ -n "${RTW89-}" ]; then
#     bash "$INIT_MODULES"/install-wifi-rtw89.sh
# fi

################################### <---------- BEGIN ----------> ##################################
if [ "${NVM-}" = "true" ]; then

    ###################################
    if [ -z "${NVM_DIR-}" ]; then
        echo_headline "CONFIGURE NVM BASHRC"
        add_to_bashrc "$(
            cat <<'EOF'
export NVM_DIR="$HIDDEN_HOME"/nvm
source_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" $1                # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion 
}
source_nvm
EOF
        )"
        set +euo pipefail
        . "$CUSTOM_BASHRC"
        set -euo pipefail
        need_resourcing=true
    fi

    ###################################
    headline="NVM"
    if [ -d "$NVM_DIR" ]; then
        echo_headline "UPDATE $headline"
    else
        echo_headline "INSTALL $headline"
        git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        cat >"$NVM_DIR"/default-packages <<'EOF'
yarn
syncyarnlock
all-the-package-names
gitpkg
bash-language-server
EOF
        need_resourcing=true
    fi
    cd "$NVM_DIR"
    git fetch --tags origin
    git checkout $(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1))
    set +euo pipefail
    source_nvm --no-use
    if [ ! -d "$NVM_DIR"/versions/node/"$(nvm ls-remote --lts | tail -1 |
        awk '{ print $2 }' | sed -r "s/\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?m//g")" ]; then

        echo -e "\n<---------- INSTALL LATEST NODE LTS ---------->\n"
        nvm install --lts
    fi
    set -euo pipefail

    # <---------- FISH NVM PLUGINS ---------->
    if type fish >/dev/null 2>&1; then
        mkdir -p "$HOME_CONFIG"/fish

        ###################################
        headline="FISH NVM COMPLETIONS"
        plugin_nvm="$HIDDEN_HOME"/plugin-nvm
        if [ -d "$plugin_nvm" ]; then
            echo_headline "UPDATE $headline"
            cd "$plugin_nvm"
            msg="$(git pull)"
            echo "$msg"
        else
            echo_headline "INSTALL $headline"
            git clone https://github.com/derekstavis/plugin-nvm.git "$plugin_nvm"
        fi
        if [ "${1-}" = "-f" ]; then
            cp -Rs --remove-destination "$plugin_nvm"/completions "$HOME_CONFIG"/fish/
        elif [ "$msg" != "$ALREADY_UTD" ]; then
            cp -Rs "$plugin_nvm"/completions "$HOME_CONFIG"/fish/ || :
        fi
        msg=''

        ###################################
        headline="BASS"
        bass="$HIDDEN_HOME"/bass
        if [ -d "$bass" ]; then
            echo_headline "UPDATE $headline"
            cd "$bass"
            msg="$(git pull)"
            echo "$msg"
        else
            echo_headline "INSTALL $headline"
            git clone https://github.com/edc/bass "$bass"
        fi
        if [ "${1-}" = "-f" ]; then
            cp -Rs --remove-destination "$bass"/functions "$HOME_CONFIG"/fish/
        elif [ "$msg" != "$ALREADY_UTD" ]; then
            cp -Rs "$bass"/functions "$HOME_CONFIG"/fish/ || :
        fi
        msg=''

        ###################################
        nvm_fish="$HOME_CONFIG"/fish/functions/nvm.fish
        if [ "${1-}" = "-f" ] || [ ! -f "$nvm_fish" ]; then
            echo_headline "INSTALL nvm.fish"
            cat >"$nvm_fish" <<'EOF'
function nvm
    bass source "$NVM_DIR"/nvm.sh --no-use ';' nvm $argv
end       
EOF
        fi

        ###################################
        load_nvm_fish="$HOME_CONFIG"/fish/functions/load_nvm.fish
        if [ "${1-}" = "-f" ] || [ ! -f "$load_nvm_fish" ]; then
            echo_headline "INSTALL load_nvm.fish"
            cat >"$load_nvm_fish" <<'EOF'
function load_nvm --on-variable="PWD"
    if test \( -f package.json \) -o \( -f .nvmrc \)
        set -l default_node_version (nvm version default)
        set -l node_version (nvm version)
        if test -f .nvmrc
            set -l nvmrc_node_version (nvm version (cat .nvmrc))
            if test "$nvmrc_node_version" = "N/A"
                nvm install (cat .nvmrc)
            else if test nvmrc_node_version != node_version
                nvm use "$nvmrc_node_version"
            end
        else if test "$node_version" != "$default_node_version"
            echo "Reverting to default Node version"
            nvm use default
        end
    end
end       
EOF
        fi

    fi
fi
################################### <---------- END ----------> ##################################

###################################
headline="RUSTUP"
if [ "${RUST-}" = "true" ]; then
    if type rustup >/dev/null 2>&1; then
        echo_headline "UPDATE $headline"
        rustup update
    else
        echo_headline "INSTALL $headline"
        curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
    fi
    # if [ "$PATH" = "${PATH//$HOME\/.cargo\/bin/}" ]; then
    if ! type cargo >/dev/null 2>&1; then
        echo_headline "CONFIGURE CARGO BASHRC"
        add_to_bashrc '. "$HOME"/.cargo/env'
        need_resourcing=true
    fi
fi

# <---------- Do you need to resource shell to use the updates ? ---------->
###################################
if [ "$(basename "${BASH_SOURCE[1]-}")" != "init.sh" ]; then
    if [ "${need_resourcing-}" = "true" ]; then
        cd "$HOME"
        . "$CUSTOM_BASHRC"
        if type fish >/dev/null 2>&1; then
            exec fish
        else
            exec bash
        fi
    fi
else
    if [ "${need_resourcing-}" = "true" ]; then
        echo -e "${YELLOW}WARNING: Reload shell to use newest installed packages${NC}"
    fi
fi
