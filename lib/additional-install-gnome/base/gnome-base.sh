#!/bin/bash

_DIR_GNOME_BASE=$(dirname ${0})
_DIR_GNOME_BASE_TEMP=${_DIR_GNOME_BASE}/tmp/base

#######################
###       Base      ###
#######################
function gnome_base() {
    mkdir -p ${_DIR_GNOME_BASE_TEMP}

    sudo pacman --noconfirm -S "${BASE_PACKAGES[@]}"
    git clone https://aur.archlinux.org/yay.git ${_DIR_GNOME_BASE_TEMP}/yay/
    $(cd ${_DIR_GNOME_BASE_TEMP}/yay && makepkg -si --noconfirm)
    yes | yay -Syu "${ADDITIONAL_YAY_PACKAGES[@]}"
    sudo pacman --noconfirm -S "${ADDITIONAL_PACMAN_PACKAGES[@]}"
    sudo systemctl enable cups.service
    sudo systemctl enable avahi-daemon.service
    sudo systemctl enable gdm.service

    dconf write /org/gnome/desktop/sound/event-sounds "false"

    sudo pacman --noconfirm -R "${TO_REMOVE_PACMAN_PACKAGES[@]}"

    return 0
}
#######################
###    ENDOF Base   ###
#######################
