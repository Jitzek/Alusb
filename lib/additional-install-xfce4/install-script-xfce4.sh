#!/bin/bash

_DIR_XFCE4=$(dirname ${0})
_TEMP_XFCE4=${_DIR_XFCE4}/tmp/
source "${_DIR_XFCE4}/../prompt.sh"
source "${_DIR_XFCE4}/form-xfce4.sh"

## Configurable variables ##
home_dir=""
prerequisites=("")
base_packages=("xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings" "git")
additional_yay_packages=("pamac-aur")
additional_pacman_packages=("firefox" "file-roller" "gvfs" "catfish")

function main() {
    mkdir ${_TEMP_XFCE4}
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
    yay --noconfirm -Syu "${additional_yay_packages[@]}"
    sudo pacman --noconfirm -S "${additional_pacman_packages[@]}"

    #########################
    ###   Configuration   ###
    #########################
    tar -xvzf "${_DIR_XFCE4}/payloads.tar.gz" -C "${_DIR_XFCE4}"
    mkdir ~/.icons ~/.themes
    mkdir ~/.config/xfce4 ~/.config/xfce4/xfconf
    cp -rf ${_DIR_XFCE4}/payloads/home/icons/* ${home_dir}/.icons/
    # Clone Papirus icons
    git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git ${_TEMP_XFCE4}
    cp -rf ${_TEMP_XFCE4}/Papirus ${home_dir}/.icons/
    cp -rf ${_TEMP_XFCE4}/Papirus-Dark ${home_dir}/.icons/
    cp -rf ${_DIR_XFCE4}/payloads/home/themes/* ${home_dir}/.themes/
    cp -rf ${_DIR_XFCE4}/payloads/home/config/gtk-2.0 ${home_dir}/.config/
    cp -rf ${_DIR_XFCE4}/payloads/home/config/gtk-3.0 ${home_dir}/.config/
    cp -rf ${_DIR_XFCE4}/payloads/home/config/xfce-perchannel-xml ${home_dir}/.config/xfce4/xfconf/
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done

    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_XFCE4}
}

main
