#!/bin/bash

source "./lib/partitioning.sh"
source "./lib/user-input.sh"

function main () {
    partitionDisk
}

function partitionDisk() {
    printf "Which block device should Linux be installed on?\n\n"

    listBlockDevices

    printf "\n"

    while true; do
        read -p "Please insert the name of the block device: " block_device
        printf 'Given block device: "%s". Is this correct?\n' "/dev/$block_device"
        if [ confirmedByUser ]; then
            break
        fi
    done

    while true; do
        clear

        printf "/dev/%s \n\n" "$block_device"

        printf "Insert Swap partition size (leave empty or 0 (or less) for no swap)\n"
        printf "Only use numbers, suffix can be given later\n"
        read swap_size

        suffix="MB"
        read "Determine suffix (default: ${suffix}), Swap will be created using gdisk: " swap_size_suffix

        has_swap=true
        [ -z "$swap_size" ] || [ $swap_size -lt 1 ] && has_swap=false

        if [ ! $has_swap ]; then
            printf "No Swap partition will be created"
        fi

        gdiskPartition $swap_size $swap_size_suffix false

        printf "\nWrite to disk?"

        if [ confirmedByUser ]; then
            clear
            # gdiskPartition $swap_size $swap_size_suffix true
            break
        fi
    done

    # mkfs.fat -F32 /dev/${block_device}2
    # mkfs.ext4 /dev/${block_device}3
    # if [ $has_swap ]; then
    #    mkswap /dev/${block_device}4
    # fi
}

main