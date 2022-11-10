#!/bin/bash

_DIR_GNOME_BASE=$(dirname ${0})

#######################
###       Base      ###
#######################
function gnome_base() {
    sudo pacman --noconfirm -S "${BASE_PACKAGES[@]}"
    git clone https://aur.archlinux.org/yay-git.git ${_TEMP_XFCE4}/yay/
    $(cd ${_TEMP_XFCE4}/yay && makepkg -si --noconfirm)
    yay --noconfirm -Syu "${ADDITIONAL_YAY_PACKAGES[@]}"
    sudo pacman --noconfirm -S "${ADDITIONAL_PACMAN_PACKAGES[@]}"
    sudo systemctl enable cups.service
    sudo systemctl enable avahi-daemon.service
    sudo systemctl enable gdm.service

    dconf write /org/gnome/desktop/sound/event-sounds "false"

    return 0
}
#######################
###    ENDOF Base   ###
#######################
