#!/bin/bash

_DIR_KDE=$(dirname ${0})
_TEMP_KDE=${_DIR_KDE}/tmp/

source "${_DIR_KDE}/lib/general/prompt.sh"

source "${_DIR_KDE}/lib/additional-install-kde/base/data/kde-base-data.sh"
source "${_DIR_KDE}/lib/additional-install-kde/base/form-kde-base.sh"
source "${_DIR_KDE}/lib/additional-install-kde/base/kde-base.sh"

source "${_DIR_KDE}/lib/additional-install-kde/nvidia/data/kde-nvidia-data.sh"
source "${_DIR_KDE}/lib/additional-install-kde/nvidia/form-kde-nvidia.sh"
source "${_DIR_KDE}/lib/additional-install-kde/nvidia/kde-nvidia.sh"

source "${_DIR_KDE}/lib/additional-install-kde/theming/kde-theming.sh"

function main() {
    mkdir ${_TEMP_KDE}
    sudo pacman --noconfirm -Syu "${prerequisites[@]}"

    ######################
    ###      Base      ###
    ######################
    while true; do
        printf "\nInstall Base?\n"
        if ! prompt; then
            break
        fi
        form_kde_base
        if kde_base; then
            break
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
        if ! prompt; then
            break
        fi
        form_kde_nvidia
        if kde_nvidia; then
            break
        fi
    done
    ########################
    ###   ENDOF Nvidia   ###
    ########################


    #########################
    ###      Theming      ###
    #########################
    while true; do
        printf "\nInstall Theming?\n"
        if ! prompt; then
            break
        fi
        ## Requires home directory to be configured
        form_kde_base
        if kde_theming; then
            break
        fi
    done
    #########################
    ###   ENDOF Theming   ###
    #########################


    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_KDE}
}

main
