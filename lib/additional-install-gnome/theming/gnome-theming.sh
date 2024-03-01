#!/bin/bash

_DIR_GNOME_THEMING_TEMP=${_DIR_GNOME_BASE}/tmp/gnome-theming

##########################
###       Theming      ###
##########################
function gnome_theming() {
    mkdir -p ${_DIR_GNOME_THEMING_TEMP}

    git clone https://github.com/Jitzek/Alusb-payloads.git ${_DIR_GNOME_THEMING_TEMP}/payloads/
    unzip "${_DIR_GNOME_THEMING_TEMP}/payloads/additional-install-gnome/theming/payloads.zip" -d "${_DIR_GNOME_THEMING_TEMP}/extracted"
    
    mkdir ${home_dir}/.icons/
    mkdir ${home_dir}/.themes/
    mkdir ${home_dir}/.local/
    mkdir ${home_dir}/.local/share/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/home/icons/* ${home_dir}/.icons/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/home/themes/* ${home_dir}/.themes/

    cp -rf ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/home/config/* ${home_dir}/.config/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/home/.bashrc ${home_dir}
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done

    cp -rf ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/home/local/share/* ${home_dir}/.local/share/

    sudo chmod +x ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/grub/install.sh
    $(cd ${_DIR_GNOME_THEMING_TEMP}/extracted/payloads/grub && sudo ./install.sh)

    rm -rf ${_DIR_GNOME_THEMING_TEMP}

    return 0
}
##########################
###    ENDOF Theming   ###
##########################
