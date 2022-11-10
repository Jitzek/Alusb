#!/bin/bash

_DIR_GNOME_THEMING=$(dirname ${0})
_TEMP_GNOME_THEMING=${_TEMP_GNOME_THEMING}/tmp/gnome-theming

##########################
###       Theming      ###
##########################
function gnome_theming() {
    mkdir -p ${_TEMP_GNOME_THEMING}

    unzip "${_DIR_GNOME_THEMING}/payloads.tar.gz" -d "${_TEMP_GNOME_THEMING}"
    
    cp -rf ${_TEMP_GNOME_THEMING}/home/icons/* ${home_dir}/.icons/
    cp -rf ${_TEMP_GNOME_THEMING}/home/themes/* ${home_dir}/.themes/

    cp -rf ${_TEMP_GNOME_THEMING}/payloads/home/config/* ${home_dir}/.config/
    cp -rf ${_TEMP_GNOME_THEMING}/payloads/home/.bashrc ${home_dir}
    for d in ${home_dir}/.icons/*/; do
        gtk-update-icon-cache "$d"
    done
    for d in ${home_dir}/.themes/*/; do
        gtk-update-icon-cache "$d"
    done

    cp -rf ${_TEMP_GNOME_THEMING}/home/local/share/* ${home_dir}/.local/share/

    sudo chmod +x ${_TEMP_GNOME_THEMING}/payloads/grub/install.sh
    $(cd ${_TEMP_GNOME_THEMING}/payloads/grub && sudo ./install.sh)

    rm -rf ${_TEMP_GNOME_THEMING}

    return 0
}
##########################
###    ENDOF Theming   ###
##########################
