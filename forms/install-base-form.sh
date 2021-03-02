installBaseForm() {
    printf "Installing Base System\n\nContinue?\n"
    if ! confirmByUser; then
        false
        return
    fi

    mount "${block_device}${root_partition_num}" /mnt
    mkdir /mnt/boot
    mount "${block_device}${esp_partition_num}" /mnt/boot
    if [[ ! -z $swap_partition_size ]]; then
        swapon "${block_device}${swap_partition_num}"
    fi

    pacstrap /mnt base linux linux-firmware

    genfstab -U /mnt >> /mnt/etc/fstab

    true
    return
}