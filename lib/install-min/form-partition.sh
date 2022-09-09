function form_partition() {
    if [ "$create_boot_partitions" = true ]; then
        printf "\nCreate Boot partitions?\n"
        if prompt; then
            create_boot_partitions=true

            ## MBR partition not set
            if [[ -z $partition_mbr ]]; then
                printf "\nMBR partition not set\n"
                partition_mbr=$(form_get_first_available_partition "MBR")
                partition_number_mbr=${partition_mbr: -1}

                if [[ "$partition_mbr" == *p[0-9] ]]; then
                    partition_block_device_mbr=${partition_mbr::-2}
                else
                    partition_block_device_mbr=${partition_mbr::-1}
                fi
            fi

            ## MBR partition is empty
            if [[ -z $partition_scheme_mbr ]]; then
                printf "\nMBR partition size is empty\n"
                while true; do
                    partition_scheme_mbr="10MB"
                    printf "Insert size of MBR partition (default: %s)\n" "$partition_scheme_mbr"
                    read partition_scheme_mbr
                    if [ -z "$partition_scheme_mbr" ]; then
                        printf "Given input is empty\n"
                        continue
                    fi

                    printf "\nAn MBR partition with size ${partition_scheme_mbr} will be created.\n"
                    printf "Confirm?\n"
                    if ! prompt; then
                        continue
                    fi
                    break
                done
            fi

            ## GPT partition not set
            if [[ -z $partition_gpt ]]; then
                printf "\GPT partition not set\n"
                partition_gpt=$(form_get_first_available_partition "GPT")
                partition_number_gpt=${partition_gpt: -1}

                if [[ "$partition_gpt" == *p[0-9] ]]; then
                    partition_block_device_gpt=${partition_gpt::-2}
                else
                    partition_block_device_gpt=${partition_gpt::-1}
                fi
            fi

            ## GPT partition is empty
            if [[ -z $partition_scheme_gpt ]]; then
                printf "\GPT partition size is empty\n"
                while true; do
                    partition_scheme_gpt="500MB"
                    printf "Insert size of GPT partition (default: %s)\n" "$partition_scheme_gpt}"
                    read partition_scheme_gpt
                    if [ -z "$partition_scheme_gpt" ]; then
                        printf "Given input was empty\n"
                        continue
                    fi

                    printf "\nA GPT partition with size ${partition_scheme_gpt} will be created.\n"
                    printf "Confirm?\n"
                    if ! prompt; then
                        continue
                    fi
                    break
                done
            fi
        else
            create_boot_partitions=false
        fi
    fi

    if [[ -z $partition_root ]]; then
        printf "\Root partition not set\n"
        partition_root=$(form_get_first_available_partition "Root")
        partition_number_root=${partition_root: -1}

        if [[ "$partition_root" == *p[0-9] ]]; then
            partition_block_device_root=${partition_root::-2}
        else
            partition_block_device_root=${partition_root::-1}
        fi
    fi

    ## Root partition is empty
    if [[ -z $partition_scheme_root ]]; then
        printf "\nRoot partition will use max available size (this will leave no space for a Home partition).\n"
        printf "Confirm?\n"
        if ! prompt; then
            while true; do
                partition_scheme_root=""
                printf "Insert size of Root partition (leave empty for for max available size)\n"
                read partition_scheme_root
                if [[ -z "$partition_scheme_root" ]]; then
                    printf "\nA Root partition with the max available size will be created (no Home partition will be created).\n"
                else
                    printf "\nA Root partition with size ${partition_scheme_root} will be created.\n"
                fi
                printf "Confirm?\n"
                if ! prompt; then
                    continue
                fi
                break
            done
        fi
    fi

    ## Don't create Home partition if root is configured to take up all available space
    if [[ -z $partition_scheme_root ]]; then
        create_home_partition=false
    else
        create_home_partition=true
    fi

    ## Home partition is empty
    if [ "$create_home_partition" = true ] && [[ -z $partition_scheme_home ]]; then
        printf "\nCreate Home partition?\n"
        if prompt; then
            if [[ -z $partition_home ]]; then
                printf "\Home partition not set\n"
                partition_home=$(form_get_first_available_partition "Home")
                partition_number_home=${partition_home: -1}

                if [[ "$partition_home" == *p[0-9] ]]; then
                    partition_block_device_home=${partition_home::-2}
                else
                    partition_block_device_home=${partition_home::-1}
                fi
            fi
            printf "\nHome partition will use max available size\n"
            printf "Confirm?\n"
            if ! prompt; then
                while true; do
                    partition_scheme_home=""
                    printf "Insert size of Home partition (leave empty for for max available size)\n"
                    read partition_scheme_home
                    if [[ -z "$partition_scheme_home" ]]; then
                        printf "\nA Home partition with the max available size will be created.\n"
                    else
                        printf "\nA Home partition with size ${partition_scheme_home} will be created.\n"
                    fi
                    printf "Confirm?\n"
                    if ! prompt; then
                        continue
                    fi
                    break
                done
            fi
            create_home_partition=true
            if [ "$encrypt_home_partition" = false ]; then
                printf "\nEncrypt Home partition?\n"
                if prompt; then
                    encrypt_home_partition=true
                fi
            fi
        else
            create_home_partition=false
        fi
    fi
}

function get_first_available_partition_suffix() {
    local block_device=$1
    local block_device_ends_with_number=false
    if [[ $block_device = *[0-9] ]]; then
        block_device_ends_with_number=true
    else
        block_device_ends_with_number=false
    fi
    local block_device_start=$(($(grep -c "$(echo ${block_device} | cut -c 6-)[0-9]" /proc/partitions) + 1))
    local partition_number=$(($block_device_start))
    local partition_suffix=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number}" || echo "${partition_number}")
    echo $partition_suffix
}

function form_get_first_available_partition() {
    topic=$1
    partition=""
    while true; do
        local partition_block_device=""
        printf "Which block device should the %s partition be installed on?\n\n" "$topic"

        lsblk -no kname

        read -p "Please insert the name of the block device for the ${topic} partition: /dev/" block_device
        if [ -z "$partition_block_device" ]; then
            printf "Given input is empty\n"
            continue
        fi
        printf 'Given block device for the %s partition: "%s". Is this correct?\n' "$topic" $partition_block_device
        printf "Confirm?\n"
        if ! prompt; then
            continue
        fi

        get_first_available_partition_suffix $partition_block_device
        local partition_number=$?
        printf 'The %s will be installed on "%s"\n' "$topic" "${partition_block_device}${partition_suffix}"
        printf "Confirm?\n"
        if ! prompt; then
            continue
        fi

        break
    done

    echo "${partition_block_device}${partition_suffix}"
}
