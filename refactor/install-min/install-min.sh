#!/bin/bash
_DIR_MIN=$(dirname ${0})

source "${_DIR_MIN}/../general/prompt.sh"
source "${_DIR_MIN}/partitioning/partitioning.sh"

prerequisites=("reflector")

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    partition_min

    printf "%s" $partition_mbr
    printf "%s" $partition_gpt
    printf "%s" $partition_root
    printf "%s" $partition_home
    printf "%s" $partition_swap
}

main