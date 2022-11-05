#!/bin/bash

_DIR_GNOME=$(dirname ${0})
_TEMP_GNOME=${_DIR_GNOME}/tmp/

source "${_DIR_GNOME}/lib/general/prompt.sh"

source "${_DIR_GNOME}/lib/additional-install-gnome/base/data/gnome-base-data.sh"
source "${_DIR_GNOME}/lib/additional-install-gnome/base/form-gnome-base.sh"
source "${_DIR_GNOME}/lib/additional-install-gnome/base/gnome-base.sh"

source "${_DIR_GNOME}/lib/additional-install-gnome/nvidia/data/gnome-nvidia-data.sh"
source "${_DIR_GNOME}/lib/additional-install-gnome/nvidia/form-gnome-nvidia.sh"
source "${_DIR_GNOME}/lib/additional-install-gnome/nvidia/gnome-nvidia.sh"

function main() {
    mkdir ${_TEMP_GNOME}
    sudo pacman --noconfirm -Syu "${prerequisites[@]}"

    ######################
    ###      Base      ###
    ######################
    while true; do
        printf "\nInstall Base?\n"
        if prompt; then
            form_gnome_base
            if gnome_base; then
                break
            fi
        fi
    done
    ######################
    ###   ENDOF Base   ###
    ######################

    ########################
    ###       Nvidia     ###
    ########################
    while true; do
        printf "\nConfigure NVIDIA?\n"
        if prompt; then
            form_gnome_nvidia
            if gnome_nvidia; then
                break
            fi
        fi
    done
    ########################
    ###   ENDOF Nvidia   ###
    ########################

    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_GNOME}
}

main