#!/bin/bash

_DIR_PARTITIONING=$(dirname ${0})

mbr_code="EF02"
gpt_code="EF00"
swap_code="8200"
root_code="8300"
home_code="8302"


########################
###   Partitioning   ###
########################
function partition_min() {
    declare local BLOCK_DEVICES=($block_device_mbr)
    [[ ! "${BLOCK_DEVICES[*]} " =~ "${block_device_gpt}" ]] && BLOCK_DEVICES+=($block_device_gpt)
    [[ ! "${BLOCK_DEVICES[*]} " =~ "${block_device_swap}" ]] && BLOCK_DEVICES+=($block_device_swap)
    [[ ! "${BLOCK_DEVICES[*]} " =~ "${block_device_root}" ]] && BLOCK_DEVICES+=($block_device_root)
    [[ ! "${BLOCK_DEVICES[*]} " =~ "${block_device_home}" ]] && BLOCK_DEVICES+=($block_device_home)

    for block_device in "${BLOCK_DEVICES[@]}"; do
        printf "\nBlock Device: \"%s\":" $block_device
        [[ ! -z $partition_mbr ]] && [[ "${block_device}" == "${block_device_mbr}" ]] && printf "\n\tMBR (\"%s\"). Size: \"%s\". Code: \"%s\"" $partition_mbr $partition_scheme_mbr $mbr_code
        [[ ! -z $partition_gpt ]] && [[ "${block_device}" == "${block_device_gpt}" ]] && printf "\n\tGPT (\"%s\"). Size: \"%s\". Code: \"%s\"" $partition_gpt $partition_scheme_gpt $gpt_code
        [[ ! -z $partition_swap ]] && [[ "${block_device}" == "${block_device_swap}" ]] && printf "\n\tSWAP (\"%s\"). Size: \"%s\". Code: \"%s\"" $partition_swap $partition_scheme_swap $swap_code
        [[ ! -z $partition_root ]] && [[ "${block_device}" == "${block_device_root}" ]] && printf "\n\tROOT (\"%s\"). Size: \"%s\". Code: \"%s\"" $partition_root $partition_scheme_root $root_code
        [[ ! -z $partition_home ]] && [[ "${block_device}" == "${block_device_home}" ]] && printf "\n\tHOME (\"%s\"). Size: \"%s\". Code: \"%s\"" $partition_home $partition_scheme_home $home_code
    done
    printf "\nAn empty size means that the partition will take up all the remaining space on the block device\n"
    
    printf "Write to disk?\n"
    if ! prompt; then
        return 1
    fi
    gdisk_partition_all true
    return 0
}

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean
#% DESCRIPTION
#% Helper function to partition all disks using gdisk
function gdisk_partition_all() {
    [[ ! -z $partition_mbr ]] && gdisk_partition $1 $block_device_mbr $partition_number_mbr $partition_scheme_mbr $mbr_code
    [[ ! -z $partition_gpt ]] && gdisk_partition $1 $block_device_gpt $partition_number_gpt $partition_scheme_gpt $gpt_code
    [[ ! -z $partition_swap ]] && gdisk_partition $1 $block_device_swap $partition_number_swap $partition_scheme_swap $swap_code
    [[ ! -z $partition_root ]] && gdisk_partition $1 $block_device_root $partition_number_root $partition_scheme_root $root_code
    [[ ! -z $partition_home ]] && gdisk_partition $1 $block_device_home $partition_number_home $partition_scheme_home $home_code
}

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean BLOCK_DEVICE:string PARTITION_NUMBER:int PARTITION_SCHEME:string PARTITION_CODE:string
#% DESCRIPTION
#% Partition disk using gdisk
function gdisk_partition() {
    local write_to_disk=$1
    local block_device=$2
    local partition_number=$3
    local partition_scheme=$4
    local partition_code=$5

    (
        echo n
        echo $partition_number
        echo ""
        
        if [[ ! -z "${partition_scheme}" ]]; then
            echo "+${partition_scheme}"
        else
            echo ""
        fi
        echo "$partition_code"

        echo p
        if $write_to_disk; then
            echo w
            echo "Y"
        fi
    ) | gdisk $block_device
}

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean BLOCK_DEVICE:string
#                 CREATE_MBR_PARTITION:boolean MBR_PARTITION_NUMBER:int MBR_PARTITION_SCHEME:string \
#                 CREATE_GPT_PARTITION:boolean GPT_PARTITION_NUMBER:int GPT_PARTITION_SCHEME:string \
#                 CREATE_SWAP_PARTITION:boolean SWAP_PARTITION_NUMBER:int SWAP_PARTITION_SCHEME:string \
#                 CREATE_ROOT_PARTITION:boolean ROOT_PARTITION_NUMBER:int ROOT_PARTITION_SCHEME:string \
#                 CREATE_HOME_PARTITION:boolean HOME_PARTITION_NUMBER:int HOME_PARTITION_SCHEME:string \
#% DESCRIPTION
#%  Partition disk using gdisk
# function gdiskPartition() {
#     write_to_disk=$1
#     block_device=$2
#     create_mbr_partition=$3
#     mbr_partition_number=$4
#     mbr_partition_scheme=$5

#     create_gpt_partition=$6
#     gpt_partition_number=$7
#     gpt_partition_scheme=$7

#     create_swap_partition=$9
#     swap_partition_number=$10
#     swap_partition_scheme=$11

#     create_root_partition=$12
#     root_partition_number=$13
#     root_partition_scheme=$14

#     create_home_partition=$15
#     home_partition_number=$16
#     home_partition_scheme=$17

#     (
#         if [ "${create_boot_partitions}" = true ]; then
#             # Creating (optional) MBR partition
#             echo n
#             echo $partition_number_mbr
#             echo ""
#             echo "+${partition_scheme_mbr}"
#             echo EF02

#             if $1; then
#                 echo p
#                 echo w
#                 echo "Y"
#             fi
#         fi

#     ) | gdisk $partition_block_device_mbr
#     (
#         if [ "${create_boot_partitions}" = true ]; then
#             # Creating (optional) GPT partition
#             echo n
#             echo $partition_number_gpt
#             echo ""
#             echo "+${partition_scheme_gpt}"
#             echo EF00

#             if $1; then
#                 echo p
#                 echo w
#                 echo "Y"
#             fi
#         fi
#     ) | gdisk $partition_block_device_gpt

#     (
#         # Creating (optional) Swap partition
#         if [[ ! -z "${partition_scheme_swap}" ]]; then
#             echo n
#             echo $partition_number_swap
#             echo ""
#             echo "+${partition_scheme_swap}"
#             echo 8200

#             if $1; then
#                 echo p
#                 echo w
#                 echo "Y"
#             fi
#         fi
#     ) | gdisk $partition_block_device_swap

#     (
#         # Creating Root partition
#         echo n
#         echo $partition_number_root
#         echo ""
#         if [[ ! -z "${partition_scheme_root}" ]]; then
#             echo "+${partition_scheme_root}"
#         else
#             echo ""
#         fi
#         echo 8300

#         if $1; then
#             echo p
#             echo w
#             echo "Y"
#         fi
#     ) | gdisk $partition_block_device_root

#     (
#         if [ "${create_home_partition}" = true ]; then
#             # Creating (optional) Home partition
#             echo n
#             echo $partition_number_home
#             echo ""
#             if [[ ! -z "${partition_scheme_home}" ]]; then
#                 echo "+${partition_scheme_home}"
#             else
#                 echo ""
#             fi
#             ## Linux Home
#             echo 8302

#             if $1; then
#                 echo p
#                 echo w
#                 echo "Y"
#             fi
#         fi
#     ) | gdisk $block_device
# }
