#!/bin/bash

_DIR_GNOME=$(dirname ${0})
_TEMP_GNOME=${_DIR_GNOME}/tmp/

source "${_DIR_GNOME}/lib/general/prompt.sh"
source "${_DIR_GNOME}/lib/additional-install-gnome/form-gnome.sh"

function main() {
    mkdir ${_TEMP_GNOME}
    sudo pacman --noconfirm -Syu "${prerequisites[@]}"

    form_gnome

    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_GNOME}
}
