#!/bin/bash

_DIR_KDE_THEMING=${_DIR_GNOME_BASE}/lib/additional-install-kde/theming
_DIR_KDE_THEMING_TEMP=${_DIR_GNOME_BASE}/tmp/kde-theming

##########################
###       Theming      ###
##########################
function gnome_theming() {
    mkdir -p ${_DIR_KDE_THEMING_TEMP}

    unzip "${_DIR_KDE_THEMING}/payloads.zip" -d "${_DIR_KDE_THEMING_TEMP}"
    
    mkdir ${home_dir}/.icons/
    mkdir ${home_dir}/.themes/
    mkdir ${home_dir}/.local/
    mkdir ${home_dir}/.local/share/
    cp -rf ${_DIR_KDE_THEMING_TEMP}/payloads/home/icons/* ${home_dir}/.icons/
    cp -rf ${_DIR_KDE_THEMING_TEMP}/payloads/home/themes/* ${home_dir}/.themes/

    cp -rf ${_DIR_KDE_THEMING_TEMP}/payloads/home/config/* ${home_dir}/.config/
    cp -rf ${_DIR_KDE_THEMING_TEMP}/payloads/home/.bashrc ${home_dir}
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done

    cp -rf ${_DIR_KDE_THEMING_TEMP}/payloads/home/local/share/* ${home_dir}/.local/share/

    sudo chmod +x ${_DIR_KDE_THEMING_TEMP}/payloads/grub/install.sh
    $(cd ${_DIR_KDE_THEMING_TEMP}/payloads/grub && sudo ./install.sh)

    rm -rf ${_DIR_KDE_THEMING_TEMP}

    return 0
}
##########################
###    ENDOF Theming   ###
##########################
