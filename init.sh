#!/bin/bash

echo "##############################"
echo "####### init.sh script #######"
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
echo_headline "CONFIG SEVERAL THINGS FIRST..."
if [ "${XDG_SESSION_DESKTOP-}" = "gnome" ]; then
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    # Disable autosuspend temporarily while init
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
fi
sudo systemctl enable --now bluetooth.service

###################################
echo_headline "INSTALL PACMAN PACKAGES"
sudo pacman -Syyu --needed base-devel github-cli gvim fish xsel signal-desktop calibre \
    lxd incron python-pip unrar git git-lfs telegram-desktop bash-language-server zellij \
    cronie noto-fonts-emoji fzf fd bat tree gimp autorandr flameshot interception-caps2esc \
    noise-suppression-for-voice nm-connection-editor xournalpp
# thunderbird vlc os-prober seahorse rsnapshot htop syncthing perl-image-exiftool
sudo pacman -Rns xterm

###################################
echo_headline "CONFIG SYSTEMD SERIVCES"
################################### <---------- BEGIN ----------> ##################################

# Delay incrond, it fails if it starts before the drive is mounted
sudo sed -i '/\[Service\]/a ExecStartPre=/bin/sleep 7' /usr/lib/systemd/system/incrond.service

# udevmon configuration for caps2esc
sudo tee /etc/interception/udevmon.d/udevmon.yaml <<'EOF'
- JOB: intercept -g $DEVNODE | caps2esc -m 1 | uinput -d $DEVNODE
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF

# id map for lxd
idmap="root:100000:65536"
subuid=/etc/subuid
subuid_content="$(cat "$subuid" 2>/dev/null || :)"
# If $idmap is replaced by nothing, and the string has not changed, then obviously $idmap was not found.
if [ "$subuid_content" = "${subuid_content/$idmap/}" ]; then
    echo "$idmap" | sudo tee -a "$subuid" >/dev/null
fi
subgid=/etc/subgid
subgid_content="$(cat "$subgid" 2>/dev/null || :)"
if [ "$subgid_content" = "${subgid_content/$idmap/}" ]; then
    echo "$idmap" | sudo tee -a "$subgid" >/dev/null
fi

sudo systemctl enable --now lxd.service
sudo systemctl enable --now cronie.service
sudo systemctl enable --now incrond.service
sudo systemctl enable --now udevmon.service
sudo systemctl enable --now autorandr.service

# echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# sudo cp /etc/rsnapshot.conf /etc/rsnapshot.conf.default
#systemctl enable --now --user syncthing.service

#
#
#
# echo -e "\n<---------- FIX BRIGHTNESS CONTROL & RESET TO MAX ON REBOOT ON LEGION 5 ---------->\n"
# content=$(
#     cat <<'EOF'
# Section "Device"
#     Identifier "Nvidia Card"
#     Driver "nvidia"
#     VendorName "NVIDIA Corporation"
#     Option "RegistryDwords" "EnableBrightnessControl=1"
# EndSection
# EOF
# )
# echo "$content" | sudo tee -a /etc/X11/xorg.conf.d/20-nvidia.conf

# system_brightness=/sys/class/backlight/nvidia_0/brightness
# (
#     sudo crontab -l
#     echo "@reboot	sleep 3 && (cat \"$HOME_CONFIG\"/brightness || echo 25) > \"$system_brightness\""
# ) | sudo crontab -
################################### <---------- END ----------> ##################################

###################################
echo_headline "CONFIG CRONIE"
# TODO: move tab-session-manager, backup ssh keys, dconf, hs_err to incrond
{
    crontab -l 2>/dev/null || :
    cat <<'EOF'
@hourly rsync -aPhhv --delete --exclude=node_modules "$HOME"/dev-sync/ "$HOME"/OneDrive/home/dev-sync
@hourly rsync -aPhhv --exclude 'node_modules' --exclude '*.git' --cvs-exclude "$HOME"/dev-sync/ "$HOME"/Dropbox/dev-sync-archive
@daily ls -d -1 "$HOME/Downloads/tab-session-manager/Auto Save - Regularly"/* | head -n -30 | xargs -d '\n' rm -f --
@daily ls -d -1 "$HOME/Downloads/tab-session-manager/Auto Save - Window closed"/* | head -n -9 | xargs -d '\n' rm -f --
@daily ls -d -1 "$HOME/Downloads/tab-session-manager/Auto Save - Browser exited"/* | head -n -9 | xargs -d '\n' rm -f --
@daily bash -c 'for file in "$HOME"/.ssh/*; do whole_name="$(basename "$file")"; filename="${whole_name\%.*}"; extension="${whole_name##*.}"; if [ "$filename" != "$extension" ] && [ "$extension" = "pub" ]; then cp "$HOME/.ssh/$filename" "$HOME/.$USER"/apps-encrypted-data/ssh/; fi; done'
@daily dconf dump / > "$HOME"/dev-sync/init/assets/dconf
@hourly mv "$HOME"/hs_err_pid* "$HOME"/.java/
EOF
} | crontab -

###################################
echo_headline "CONFIG INCROND"
{
    incrontab -l 2>/dev/null || :
    cat <<EOF
$HOME/Dropbox/Apps/Shortcuts/ToDesktop	IN_MOVED_TO	mv "$HOME"/Dropbox/Apps/Shortcuts/ToDesktop/* "$HOME"/Documents/
EOF
} | incrontab -
# $system_brightness	IN_CLOSE_WRITE	sleep 3 && cat "$system_brightness" > "$HOME"/.config/brightness

###################################
echo_headline "INSTALL AURs"
################################### <---------- BEGIN ----------> ##################################

git clone https://aur.archlinux.org/paru.git
(
    cd paru
    makepkg -si
)
rm -rf paru
sleep 1

paru -Syu google-chrome mailspring qimgv ibus-bamboo insync \
    obsidian logseq-desktop visual-studio-code-bin spotify teamviewer droidcam
# dropbox python-gpgme dropbox-cli qt-heif-image-plugin

# Unload droidcam audio loopback device (never use)
sudo sed -i 's/snd-aloop/# snd-aloop/g' /etc/modules-load.d/droidcam.conf

read -rp "Nvidia driver ? [y/n, default=y] " nvidia
if [ "${nvidia:-y}" = "y" ]; then
    paru -S nvidia nvidia-container-toolkit
fi

read -rp "Nvidia prime ? [y/n, default=n] " prime
if [ "${prime:-n}" = "y" ]; then
    paru -S nvidia-prime optimus-manager
    if type gdm >/dev/null 2>&1; then
        paru -S gdm-prime
        sudo sed -i 's/#WaylandEnable/WaylandEnable/g' /etc/gdm/custom.conf
    fi
    sudo tee etc/optimus-manager/optimus-manager.conf <<'EOF'
[optimus]
startup_mode=hybrid
EOF
fi

paru -S cryptomator || :
echo -e "\n${YELLOW}WARNING: Cryptomator need 2 paru run to be installed due to a bug, please reboot first and reinstall it${NC}\n"
read -rp "Enter to continue\n" r

insync start

#sudo mv /usr/bin/dropbox /usr/bin/dropbox.bak
#sparse="$HOME"/.ext4-sparse-file.img
#ext4_mount_point="$HOME"/.ext4
#dd if=/dev/zero of="$sparse" bs=1 count=0 seek=20GiB
#mkfs.ext4 "$sparse"
#mkdir -p "$ext4_mount_point"
#sudo mount "$sparse" "$ext4_mount_point"
#sudo chown "$USER":"$USER" "$ext4_mount_point"
#ln -s "$ext4_mount_point"/Dropbox "$HOME"/Dropbox
#echo ""$sparse" "$ext4_mount_point" ext4 loop,defaults 0 0" | sudo tee -a /etc/fstab
################################### <---------- END ----------> ##################################

################################### <---------- BEGIN ----------> ##################################
if [ "${XDG_SESSION_DESKTOP-}" = "gnome" ]; then
    ###################################
    echo_headline "CONFIG GNOME"

    paru -S libappindicator-gtk2 libappindicator-gtk3 gnome-shell-extension-appindicator \
        gnome-shell-extension-bluetooth-quick-connect gnome-shell-extension-sound-output-device-chooser \
        gnome-shell-extension-unite gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-clipboard-history gnome-shell-extension-ddterm \
        touchegg gnome-shell-extension-x11gestures \
        gnome-browser-connector

    sudo systemctl enable --now touchegg.service

    # Cronie backup dconf
    {
        crontab -l 2>/dev/null || :
        cat <<'EOF'
@hourly dconf dump / > "$HOME"/dev-sync/init/assets/dconf
EOF
    } | crontab -
fi
################################### <---------- END ----------> ##################################

###################################
echo_headline "INIT .BASHRC"
init_bashrc -fcb

###################################
echo_headline "RUN CONFIGURATIONS SCRIPTS"
add_to_configs
bash "$INIT_MODULES"/link-configs.sh
git_config
# TODO: detect gnome-keyring, pam, headless,...etc.
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# Week start on monday
# echo "en_GB.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
# sudo locale-gen
# localectl set-locale LC_TIME=en_GB.UTF-8

###################################
echo_headline "INSTALL CUSTOM PACKAGES"
bash "$INIT_MODULES"/update-pkgs.sh

# echo -e "\n<---------- SETUP AUTO DECRYPT SWAP ---------->\n"
# sleep 3
# sudo dd if=/dev/urandom of=/root/keyfile bs=1024 count=4
# sudo chmod 0400 /root/keyfile
# lsblk
# read -rp "Name of swap device (/dev/some_device): " swap_device
# sudo cryptsetup luksAddKey /dev/"$swap_device" /root/keyfile
# cat /etc/fstab
# read -rp "Please modify /etc/crypttab to use decrypt device with /root/keyfile, enter to proceed" r
# sudo gedit /etc/crypttab >/dev/null 2>&1

# fix dash-to-dock error
#cd /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
#sudo mv schemas schemas.bak
#dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
#dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts false

read -rp "\n<---------- THE END, PRESS ANY KEY TO REBOOT NOW ---------->\n" r
reboot
