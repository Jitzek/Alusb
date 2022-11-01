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

    partition_min

    printf "\n%s\n" $partition_mbr
    printf "%s\n" $partition_gpt
    printf "%s\n" $partition_root
    printf "%s\n" $partition_home
    printf "%s\n" $partition_swap
}

main