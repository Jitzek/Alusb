#!/bin/bash
_DIR_MIN=$(dirname ${0})

source "${_DIR_MIN}/lib/general/prompt.sh"

source "${_DIR_MIN}/lib/install-min/partitioning/data/partitioning-data.sh"
source "${_DIR_MIN}/lib/install-min/partitioning/form-partition.sh"
source "${_DIR_MIN}/lib/install-min/partitioning/partitioning.sh"

source "${_DIR_MIN}/lib/install-min/base/data/base-data.sh"
source "${_DIR_MIN}/lib/install-min/base/base.sh"
source "${_DIR_MIN}/lib/install-min/base/form-base.sh"

prerequisites=("reflector")

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ##############################
    ###      Partitioning      ###
    ##############################
    while true; do
        printf "\nPartition Disks?\n"
        if prompt; then
            form_partition_min
            if partition_min; then
                break
            fi
        fi
    done
    ##############################
    ###   ENDOF Partitioning   ###
    ##############################

    ##############################
    ###          Base          ###
    ##############################
    while true; do
        printf "\nInstall Base?\n"
        if prompt; then
            form_base_min
            base_min
            break
        fi
    done
    ##############################
    ###       ENDOF Base       ###
    ##############################
}

main