#!/bin/bash

_DIR_XFCE4=$(dirname ${0})
source "${_DIR_XFCE4}/../prompt.sh"
source "${_DIR_XFCE4}/form-xfce4.sh"

## Configurable variables ##
home_dir=""
additional_packages=("firefox" "file-roller" "gvfs")


function main() {
    ## Fill all user determined variables
    form_xfce4

    ################
    ###   Base   ###
    ################
    sudo pacman --noconfirm -Syu
    sudo pacman --noconfirm -S xorg base-devel
    sudo pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings git
    sudo systemctl enable lightdm
    git clone https://aur.archlinux.org/yay-git.git
    $(cd ./yay-git && makepkg -si --noconfirm)
    yay --noconfirm -Syu pamac-aur

    #########################
    ###   Configuration   ###
    #########################
    sudo pacman --noconfirm -S additional_packages[@]
    tar –xvzf "${_DIR_XFCE4}/payloads.tar.gz"
}

main