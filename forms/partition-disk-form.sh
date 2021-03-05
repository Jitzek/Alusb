source "./forms/form.sh"

function partitionDiskForm() {
    clear
    printf "\nPartitioning Disk\n\nContinue?\n\n"
    if ! prompt; then
        false
        return
    fi
    if ! form "Disk Partitioning" step1_getBlockDevice step2_createOptionalSwap step3_partitionDisk; then
        false
        return
    fi
    true
    return
}

function step1_getBlockDevice() {
    while true; do
        # Reset block device
        block_device=""

        printf "Which block device should Linux be installed on?\n\n"

        listBlockDevices

        printf '\nType ":cancel" to exit\n'
        read -p "Please insert the name of the block device: /dev/" block_device
        if [ $block_device == ":cancel" ]; then
            # Reset block device
            block_device=""
            false
            return
        fi
        block_device="/dev/$block_device"
        printf 'Given block device: "%s". Is this correct?\n' $block_device
        if prompt; then
            break
        fi
    done
}

function step2_createOptionalSwap() {
    # Reset Swap partition size
    swap_partition_size=""

    clear
    printf "Block Device: %s \n\n" "$block_device"
    printf "Create a Swap partition?\n"
    if ! prompt; then
        true
        return
    fi
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
            if prompt; then
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
        if prompt; then
            break
        fi
    done
    true
    return
}

function step3_partitionDisk() {
    # Display result of partitioning to user without writing to disk
    gdiskPartition $block_device false

    printf "\nWrite to disk?\n"

    if ! prompt; then
        false
        return
    fi

    clear
    # Partition and write to disk
    # gdiskPartition $block_device true
    break

    mkfs.fat -F32 "${block_device}${esp_partition_num}"
    mkfs.ext4 "${block_device}${root_partition_num}"
    if [ $has_swap ]; then
        mkswap "${block_device}${swap_partition_num}"
    fi

    true
    return
}