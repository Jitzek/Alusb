#!/bin/bash

# The block device to partition
block_device=""

mbr_partition_num="1"
esp_partition_num="2"
root_partition_num="3"
swap_partition_num="4"

# The MBR partition defaults to 10MB
mbr_partition_size="10MB"

# The ESP partition defaults to 500MB
esp_partition_size="500MB"

# The Swap partition defaults to false unless requested by user
swap_partition_size=""

# The Root partition defaults to empty and will therefore take up all leftover available space
# (after the other partitions are created)
root_partition_size=""

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean
#% DESCRIPTION 
#%  Partition disk using gdisk
function gdiskPartition() {
    (
        # Creating MBR partition
        echo d
        echo n
        echo $mbr_partition_num
        echo
        echo "+${mbr_partition_size}"
        echo EF02

        # Creating ESP partition
        echo n
        echo $esp_partition_num
        echo
        echo "+${esp_partition_size}"
        echo EF00

        # Creating (optional) Swap partition
        if [[ ! -z $swap_partition_size ]]; then
            echo n
            echo $swap_partition_num
            echo
            echo "+${swap_partition_size}"
            echo 8200
        fi


        # Creating Linux partition
        echo n
        echo $root_partition_num
        echo
        if [[ ! -z $root_partition_size ]]; then
            echo "+${root_partition_size}"
        else 
            echo
        fi
        echo 8300

        echo p
        if [ $1 ]; then
            echo w
        fi
    ) | gdisk $block_device
}

function listBlockDevices() {
    lsblk -no kname
}
