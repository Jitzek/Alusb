#!/bin/bash

_DIR_KDE_BASE=$(dirname ${0})
_DIR_KDE_BASE_TEMP=${_DIR_KDE_BASE}/tmp/base

#######################
###       Base      ###
#######################
function gnome_base() {
    mkdir -p ${_DIR_KDE_BASE_TEMP}

    sudo pacman --noconfirm -S "${BASE_PACKAGES[@]}"
    git clone https://aur.archlinux.org/yay.git ${_DIR_KDE_BASE_TEMP}/yay/
    $(cd ${_DIR_KDE_BASE_TEMP}/yay && makepkg -si --noconfirm)
    yes | yay -Syu "${ADDITIONAL_YAY_PACKAGES[@]}"
    sudo pacman --noconfirm -S "${ADDITIONAL_PACMAN_PACKAGES[@]}"
    sudo systemctl enable cups.service
    sudo systemctl enable avahi-daemon.service
    sudo systemctl enable sddm.service

    sudo pacman --noconfirm -R "${TO_REMOVE_PACMAN_PACKAGES[@]}"

    return 0
}
#######################
###    ENDOF Base   ###
#######################
