#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

if [ -z "${BASH_SOURCE-}" ]; then
    echo -e "${RED}ERROR: This script is only compatible with bash, last parent is $(realpath "${BASH_SOURCE[1]}"), halt...${NC}"
    sleep 259200
fi

if [ "$BASH_SOURCE" = "$0" ]; then
    echo -e "${RED}ERROR: Not sourcing $BASH_SOURCE, last parent is $(realpath "${BASH_SOURCE[1]}"), halt...${NC}"
    sleep 259200
fi

HOME_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
USR_LOCAL_BIN=/usr/local/bin
LOCAL_BIN="$HOME"/.local/bin

INIT_DIR="$HOME"/dev-sync/init
INIT_MODULES="$INIT_DIR"/init-modules
INIT_BIN="$INIT_DIR"/bin
USER="$(whoami)"
HIDDEN_HOME="$HOME"/."$USER" && mkdir -p "$HIDDEN_HOME"
CUSTOM_BASHRC="$HIDDEN_HOME"/bashrc
APPS_ENCRYPTED_DATA="$HIDDEN_HOME"/apps-encrypted-data

echo_headline() {
    echo -e "\n${GREEN}<---------- ${1:?} ---------->${NC}\n"
}

add_to_bashrc() {
    # If .bashrc does not source custom bashrc
    bashrc_content="$(cat "$HOME"/.bashrc)"
    source_custom="$(echo ". \"$CUSTOM_BASHRC\"" | sed "s|$HOME|\$HOME|g" | sed "s|$USER|\$(whoami)|g")"
    if [ "$bashrc_content" = "${bashrc_content/$source_custom/}" ]; then
        echo "$source_custom" >>"$HOME"/.bashrc
    fi

    ###################################
    # Add to custom bashrc
    to_bashrc=to-bashrc
    tmp_bashrc=tmp-bashrc
    # Copy to tmp file
    echo "${1:?}" >"$to_bashrc"
    # If there's fish-launch already
    fish_launch="fish-launch"
    custom_bashrc_content="$(cat "$CUSTOM_BASHRC" 2>/dev/null || :)"
    # $custom_bashrc_content contains '# fish_launch'
    if [ "$custom_bashrc_content" != "${custom_bashrc_content/\# $fish_launch/}" ]; then
        # Input !=replace-me=! above fish-launch, and then replace it
        sed "/# $fish_launch/i !=replace-me=!\n" "$CUSTOM_BASHRC" | sed "/!=replace-me=!/ {                  
r $to_bashrc
d 
}" >"$tmp_bashrc"
        # Notice that we use a tmp here to avoid race condition when read and write to same file in same pipe.
        # We also call `sync` before the mv to assure no data loss when crashing,
        # see https://mywiki.wooledge.org/BashPitfalls#pf13
        sync
        mv "$tmp_bashrc" "$CUSTOM_BASHRC"
    else
        cat "$to_bashrc" >>"$CUSTOM_BASHRC"
    fi
    rm "$to_bashrc"
}

init_bashrc() {
    if [ ! -f "$CUSTOM_BASHRC" ]; then
        add_to_bashrc "$(
            cat <<'EOF'
HIDDEN_HOME="$HOME/.$(whoami)"

export VISUAL=vim
export PATH="$HOME/.local/bin:$PATH"

# fish-launch
if type fish >/dev/null 2>&1 && [[ "${BASH_SOURCE[1]}" = "$HOME"/.bashrc && $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]; then
    exec fish
fi
EOF
        )"

        local OPTIND opt
        while getopts 'fcbnr' opt; do
            # shellcheck disable=SC2220
            case "$opt" in
            f)
                add_to_bashrc "FIREFOX_CUSTOM=true"
                ;;
            c)
                add_to_bashrc "FIRA_CODE=true"
                ;;
            b)
                add_to_bashrc 'export BASH_OO="$HIDDEN_HOME"/bash-oo-framework/lib'
                ;;
            n)
                add_to_bashrc "NVM=true"
                ;;
            r)
                add_to_bashrc "RUST=true"
                ;;
            esac
        done
        shift $((OPTIND - 1))
    fi
}

add_to_configs() {

    if [ "${XDG_SESSION_DESKTOP-}" = "gnome" ]; then

        # Padding gnome-terminal (and VTE-like)
        gtk_css="$HOME_CONFIG"/gtk-3.0/gtk.css
        gtk_css_content="$(cat "$gtk_css" 2>/dev/null || :)"
        comment="Padding gnome-terminal"
        if [ "$gtk_css_content" = "${gtk_css_content/\/\* $comment \*\//}" ]; then
            echo "******* $comment"
            cat >>"$HOME_CONFIG"/gtk-3.0/gtk.css <<EOF
/* $comment */
VteTerminal,
TerminalScreen,
vte-terminal {
    padding: 20px 20px 20px 20px; /* vte <= 0.36 */
    -VteTerminal-inner-border: 20px 20px 20px 20px; /* vte >= 0.38 */
}
EOF
        fi

        # File explorer bookmarks
        gtk_bookmarks="$HOME_CONFIG"/gtk-3.0/bookmarks
        gtk_bookmarks_content="$(cat "$gtk_bookmarks" 2>/dev/null || :)"
        if [ "$gtk_bookmarks_content" = "${gtk_bookmarks_content/file\:\/\/$HOME\/dev-sync/}" ]; then
            echo '******* Add file explorer bookmarks'
            cat >>"$HOME_CONFIG"/gtk-3.0/bookmarks <<EOF
file://$HOME/dev-sync
file://$HOME/OneDrive
file://$HOME/Dropbox
file://$HOME/Desktop
EOF
        fi

    fi

}

ln_Tfs_dir() {
    # Symlink dir, rename/delete existing dir
    local OPTIND opt delete target destination

    while getopts 'd' opt; do
        # shellcheck disable=SC2220
        case "$opt" in
        d)
            delete=true
            ;;
        esac
    done
    shift $((OPTIND - 1))

    target="${1:?}"
    destination="${2:?}"
    if [ ! -L "$destination" ] && [ -d "$destination" ]; then
        if [ "${delete-}" = "true" ]; then
            rm -rf "$destination"
        else
            mv "$destination" "$destination".old
        fi
    fi
    ln -Tfs "$target" "$destination"
}

git_config() {
    if [ ! -f "$HOME"/.gitconfig ]; then
        git config --global init.defaultBranch main
        git config --global credential.helper cache
        git config --global diff.submodule log
        git config --global pull.rebase true
        git config --global rebase.autoStash true
        if type git-lfs >/dev/null 2>&1; then
            git lfs install # `git lfs install` is a configuration command, it should've been `git lfs initialize`
        fi
        if [ -L "$INIT_MODULES"/git-sig.sh ]; then # wsl compatible, on windows the symlink might not work properly
            echo -e "${RED}ERROR: git-sig.sh is not a symlink, cannot be run${NC}"
            bash "$INIT_MODULES"/git-sig.sh "$@"
        fi
    fi
}
