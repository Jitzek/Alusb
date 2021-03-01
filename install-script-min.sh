#!/bin/bash

source "./lib/partitioning.sh"
source "./lib/user-input.sh"

function main() {
    clear
    partitionDisk
}

function partitionDisk() {
    printf "Which block device should Linux be installed on?\n\n"

    listBlockDevices

    printf "\n"

    while true; do
        read -p "Please insert the name of the block device: " block_device
        block_device="/dev/$block_device"
        printf 'Given block device: "%s". Is this correct?\n' $block_device
        if confirmByUser; then
            break
        fi
    done

    while true; do
        clear

        printf "Block Device: %s \n\n" "$block_device"

        printf "Create a Swap partition?\n"
        if confirmByUser; then
            # Reset Swap partition size
            swap_partition_size=""
            while true; do
                printf "Insert size of Swap partition\n"
                printf "Only use numbers, suffix will be asked for later\n"
                read swap_size

                if ! $isNumeric; then
                    printf "Given input is not a number\n"
                    continue
                fi

                if [ -z "$swap_size" ] || [ $swap_size -lt 1 ]; then
                    printf "Given input was empty or below 1\n"
                    printf "Continue without Swap partition?\n"
                    if confirmByUser; then
                        has_swap=false
                        break
                    fi
                    continue
                fi

                swap_size_suffix="MB"
                read -p "Determine suffix (default: ${swap_size_suffix}), Swap will be created using gdisk: " swap_size_suffix
                if [ -z "$swap_size_suffix" ]; then
                    swap_size_suffix="MB"
                fi

                # Set Swap partition size
                swap_partition_size=${swap_size}${swap_size_suffix}

                printf "\nA Swap partition with size ${swap_partition_size} will be created.\n"
                printf "Confirm?\n"
                if confirmByUser; then
                    break
                fi
            done
        fi

        # Display result of partitioning to user without writing to disk
        gdiskPartition $block_device false

        printf "\nWrite to disk?\n"

        if confirmByUser; then
            clear
            # Partition and write to disk
            # gdiskPartition $block_device true
            break
        fi
    done

    mkfs.fat -F32 ${block_device}2
    mkfs.ext4 ${block_device}3
    if [ $has_swap ]; then
        mkswap ${block_device}4
    fi
}

main
