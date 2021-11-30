#!/bin/bash

_DIR_XFCE4=$(dirname ${0})
_TEMP_XFCE4=${_DIR_XFCE4}/tmp/
source "${_DIR_XFCE4}/../prompt.sh"
source "${_DIR_XFCE4}/form-xfce4.sh"

## Configurable variables ##
home_dir=""
prerequisites=("")
base_packages=("xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings" "git" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "network-manager-applet" "pavucontrol")
# Maybe replace ttf-liberation with official microsoft fonts (see: https://wiki.archlinux.org/title/Microsoft_fonts#Installation)
additional_yay_packages=("pamac-aur" "ttf-liberation") 
additional_pacman_packages=("firefox" "firefox-adblock-plus" "file-roller" "gvfs" "catfish" "gedit" "xed" "thunderbird")

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
    git clone https://aur.archlinux.org/yay-git.git ${_TEMP_XFCE4}/yay/
    $(cd ${_TEMP_XFCE4}/yay && makepkg -si --noconfirm)
    yay --noconfirm -Syu "${additional_yay_packages[@]}"
    sudo pacman --noconfirm -S "${additional_pacman_packages[@]}"

    #########################
    ###   Configuration   ###
    #########################
    tar -xvzf "${_DIR_XFCE4}/payloads.tar.gz" -C "${_DIR_XFCE4}"
    mkdir ${home_dir}/.icons ${home_dir}/.themes
    mkdir -p ${home_dir}/.config/xfce4/xfconf
    cp -rf ${_DIR_XFCE4}/payloads/home/.icons/* ${home_dir}/.icons/
    # Clone Papirus icons
    git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git ${_TEMP_XFCE4}/papirus/
    sudo cp -rf ${_TEMP_XFCE4}/papirus/Papirus /usr/share/icons/
    sudo cp -rf ${_TEMP_XFCE4}/papirus/Papirus-Dark /usr/share/icons/
    sudo cp -rf ${_DIR_XFCE4}/payloads/home/.themes/* /usr/share/themes/
    sudo cp -rf ${_DIR_XFCE4}/payloads/usr/share/backgrounds/* /usr/share/backgrounds/
    sudo cp -rf ${_DIR_XFCE4}/payloads/etc/lightdm/* /etc/lightdm/
    cp -rf ${_DIR_XFCE4}/payloads/home/.config/* ${home_dir}/.config/
    cp -rf ${_DIR_XFCE4}/payloads/home/.bashrc ${home_dir}
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done
    sudo cp -rf ${_DIR_XFCE4}/payloads/usr/share/gtksourceview-4/styles/* /usr/share/gtksourceview-4/styles/
    mkdir -p ${home_dir}/.local/share/xfce4/terminal/colorschemes/
    cp -rf ${_DIR_XFCE4}/payloads/home/.local/share/xfce4/terminal/colorschemes/* ${home_dir}/.local/share/xfce4/terminal/colorschemes/
    
    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_XFCE4}
}

main
