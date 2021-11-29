#!/bin/bash

_DIR_XFCE4=$(dirname ${0})
source "${_DIR_XFCE4}/../prompt.sh"
source "${_DIR_XFCE4}/form-xfce4.sh"

## Configurable variables ##
home_dir=""
prerequisites=("")
base_packages=("xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings" "git")
additional_pacman_packages=("firefox" "file-roller" "gvfs", "catfish")


function main() {
    sudo pacman --noconfirm -Syu "${prerequisites[@]}"

    ## Fill all user determined variables
    form_xfce4

    ################
    ###   Base   ###
    ################
    sudo pacman --noconfirm -S xorg base-devel
    sudo pacman --noconfirm -S "${base_packages[@]}"
    sudo systemctl enable lightdm
    git clone https://aur.archlinux.org/yay-git.git
    $(cd ./yay-git && makepkg -si --noconfirm)
    yay --noconfirm -Syu pamac-aur

    #########################
    ###   Configuration   ###
    #########################
    sudo pacman --noconfirm -S "${additional_pacman_packages[@]}"
    tar -xvzf "${_DIR_XFCE4}/payloads.tar.gz" -C "${_DIR_XFCE4}"
    cp -rf "${_DIR_XFCE4}/payloads/icons/*" "${home_dir}/.icons/"
    cp -rf "${_DIR_XFCE4}/payloads/themes/*" "${home_dir}/.themes/"
    cp -rf "${_DIR_XFCE4}/payloads/config/gtk-2.0" "${home_dir}/.config/"
    cp -rf "${_DIR_XFCE4}/payloads/config/gtk-3.0" "${home_dir}/.config/"
    cp -rf "${_DIR_XFCE4}/payloads/config/xfce-perchannel-xml" "${home_dir}/.config/xfce4/xfconf/"
}

main