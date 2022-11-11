#!/bin/bash

_DIR_GNOME_THEMING=$(dirname ${0})
_DIR_GNOME_THEMING_TEMP=${_DIR_GNOME_THEMING}/tmp/gnome-theming

##########################
###       Theming      ###
##########################
function gnome_theming() {
    mkdir -p ${_DIR_GNOME_THEMING_TEMP}

    unzip "${_DIR_GNOME_THEMING}/payloads.zip" -d "${_DIR_GNOME_THEMING_TEMP}"
    
    mkdir ${home_dir}/.icons/
    mkdir ${home_dir}/.themes/
    mkdir ${home_dir}/.local/
    mkdir ${home_dir}/.local/share/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/payloads/home/icons/* ${home_dir}/.icons/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/payloads/home/themes/* ${home_dir}/.themes/

    cp -rf ${_DIR_GNOME_THEMING_TEMP}/payloads/home/config/* ${home_dir}/.config/
    cp -rf ${_DIR_GNOME_THEMING_TEMP}/payloads/home/.bashrc ${home_dir}
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done

    cp -rf ${_DIR_GNOME_THEMING_TEMP}/payloads/home/local/share/* ${home_dir}/.local/share/

    sudo chmod +x ${_DIR_GNOME_THEMING_TEMP}/payloads/grub/install.sh
    $(cd ${_DIR_GNOME_THEMING_TEMP}/payloads/grub && sudo ./install.sh)

    rm -rf ${_DIR_GNOME_THEMING_TEMP}

    return 0
}
##########################
###    ENDOF Theming   ###
##########################
