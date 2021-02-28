#!/bin/bash

partitionDisk

partitionDisk() {
    printf "Which block device should Linux be installed on?\n\n"

    lsblk -no kname

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

    mkfs.fat -F32 /dev/${block_device}2
    mkfs.ext4 /dev/${block_device}3
    if [ $has_swap ]; then
        mkswap /dev/${block_device}4
    fi
}

confirmedByUser() {
    read -p "Y/y/N/n" yn

    valid_input=('Y' 'y' 'N' 'n')
    while [[ " ${valid_input[@]} " =~ " ${yn} " ]]; do
        printf "Y/y/N/n expected\n"
        read -p "Y/y/N/n: " yn
    done
    if [[ $yn == 'N' ]] || [[ $yn == 'n' ]]; then
        return false
    fi
    return true
}

gdiskPartition() {
    (
        # Creating MBR partition
        echo d
        echo n
        echo 1
        echo
        echo +10MB
        echo EF02

        # Creating ESP partition
        echo n
        echo 2
        echo
        echo +500MB
        echo EF00

        # Creating (optional) Swap partition
        if [ $has_swap ]; then
            echo n
            echo 4
            echo
            echo "+${1}${2}"
            echo 8200
        fi

        # Creating Linux partition
        echo n
        echo 3
        echo
        echo
        echo 8300

        echo p
        if [ $3 ]; then
            echo w
        fi
    ) | gdisk /dev/$block_device
}
