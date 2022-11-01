#!/bin/bash
_DIR_MIN=$(dirname ${0})

source "${_DIR_MIN}/../general/prompt.sh"
source "${_DIR_MIN}/partitioning/data/partitioning-data.sh"
source "${_DIR_MIN}/partitioning/form-partition.sh"
source "${_DIR_MIN}/partitioning/partitioning.sh"

prerequisites=("reflector")

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ##############################
    ###      Partitioning      ###
    ##############################
    printf "Partition Disks?\n"
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
}

main
