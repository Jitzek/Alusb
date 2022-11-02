#!/bin/bash
_DIR_MIN=$(dirname ${0})

source "${_DIR_MIN}/../general/prompt.sh"

source "${_DIR_MIN}/partitioning/data/partitioning-data.sh"
source "${_DIR_MIN}/partitioning/form-partition.sh"
source "${_DIR_MIN}/partitioning/partitioning.sh"

source "${_DIR_MIN}/base/data/base-data.sh"
source "${_DIR_MIN}/base/base.sh"
source "${_DIR_MIN}/base/form-base.sh"

prerequisites=("reflector")

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ##############################
    ###      Partitioning      ###
    ##############################
    printf "\nPartition Disks?\n"
    if prompt; then
        while true; do
            form_partition_min
            if partition_min; then
                break
            fi
        done
    fi
    ##############################
    ###   ENDOF Partitioning   ###
    ##############################

    ##############################
    ###          Base          ###
    ##############################
    printf "\nConfigure Base?\n"
    if prompt; then
        while true; do
            form_base_min
            if base_min; then
                break
            fi
        done
    fi
    ##############################
    ###       ENDOF Base       ###
    ##############################

    printf "Installation complete!"
}

main
