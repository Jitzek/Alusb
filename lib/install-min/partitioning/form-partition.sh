_DIR_FORM_PARTITIONING=$(dirname ${0})
partition_return=""
temp_partitions_file="${_DIR_FORM_PARTITIONING}/temp_partitions"

function form_partition_min() {
    touch $temp_partitions_file
    cat /proc/partitions >$temp_partitions_file

    for ((i = 0; i < ${#PARTITION_INDEX_MAP[@]}; i++)); do
        local l_partition_key="${PARTITION_INDEX_MAP[$i]}"
        if [[ ! -z "${PARTITION_MAP[$l_partition_key]}" ]]; then
            if [[ "$l_partition_key" == "home" ]]; then
                if [[ -z "$encrypt_home_partition" ]]; then
                    printf "\nEncrypt Home partition?\n"
                    if prompt; then
                        encrypt_home_partition=true
                    fi
                fi
            fi
            continue
        fi

        local l_partition_name="$(echo $l_partition_key | awk '{print toupper($0)}')"

        printf "\n%s partition not set\n" "$l_partition_name"
        printf "Create %s partition?\n" "$l_partition_name"
        ! prompt && continue
        form_get_first_available_partition "$l_partition_name"
        PARTITION_MAP[$l_partition_key]="$partition_return"

        ## Partition is empty
        if [[ -z "${PARTITION_SCHEME_MAP[$l_partition_key]}" ]]; then
            printf "\n%s partition size is empty\n" "$l_partition_name"
            while true; do
                printf "Insert size of %s partition (Leave empty to take up all remaining space on the device)\n" $l_partition_name
                read l_partition_scheme
                if [ -z "$l_partition_scheme" ]; then
                    printf "\nA %s partition will be created and take up all remaining space on the device.\n" "$l_partition_name"
                else
                    printf "\nA %s partition with size %s will be created.\n" "$l_partition_name" "$l_partition_scheme"
                fi

                printf "Confirm?\n"
                if ! prompt; then
                    continue
                fi
                PARTITION_SCHEME_MAP[$l_partition_key]="$l_partition_scheme"
                break
            done
        fi
    done

    for l_partition_key in "${!PARTITION_MAP[@]}"; do
        [[ -z "${PARTITION_MAP[$l_partition_key]}" ]] && continue

        if [[ "${PARTITION_MAP[$l_partition_key]}" == *p[0-9] ]]; then
            BLOCK_DEVICE_MAP[$l_partition_key]="${PARTITION_MAP[$l_partition_key]::-2}"
        else
            BLOCK_DEVICE_MAP[$l_partition_key]="${PARTITION_MAP[$l_partition_key]::-1}"
        fi
        PARTITION_NUMBER_MAP[$l_partition_key]=${PARTITION_MAP[$l_partition_key]: -1}
    done

    rm $temp_partitions_file
}

function get_first_available_partition_suffix() {
    local block_device=$1
    local block_device_ends_with_number=false
    local block_device_start=0
    if [[ $block_device = *[0-9] ]]; then
        block_device_ends_with_number=true
        block_device_start=$(($(grep -c "$(echo "${block_device}p" | cut -c 6-)[0-9]" ${temp_partitions_file}) + 1))
    else
        block_device_ends_with_number=false
        block_device_start=$(($(grep -c "$(echo ${block_device} | cut -c 6-)[0-9]" ${temp_partitions_file}) + 1))
    fi
    local partition_number=$(($block_device_start))
    local partition_suffix=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number}" || echo "${partition_number}")
    echo $partition_suffix
}

function form_get_first_available_partition() {
    topic=$1
    partition_return=""
    while true; do
        local block_device=""
        printf "Which block device should the %s partition be installed on?:\n" "$topic"

        lsblk -no kname

        read -p "Please insert the name of the block device for the ${topic} partition: /dev/" block_device
        if [ -z "$block_device" ]; then
            printf "Given input is empty\n"
            continue
        fi
        block_device="/dev/${block_device}"
        printf 'Given block device for the %s partition: "%s". Is this correct?\n' "$topic" $block_device
        printf "Confirm?\n"
        if ! prompt; then
            continue
        fi

        partition_suffix=$(get_first_available_partition_suffix $block_device)

        local partition_number=$?
        printf '\nThe %s will be installed on "%s"\n' "$topic" "${block_device}${partition_suffix}"
        printf "Confirm?\n"
        if ! prompt; then
            continue
        fi

        break
    done

    partition_return="${block_device}${partition_suffix}"

    echo $partition_return >>$temp_partitions_file
}
