#!/bin/bash


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
#+ gdiskPartition BLOCK_DEVICE:string WRITE_TO_DISK:boolean
#% DESCRIPTION 
#%  Partition disk using gdisk
function gdiskPartition() {
    (
        # Creating MBR partition
        echo d
        echo n
        echo 1
        echo
        echo "+${mbr_partition_size}"
        echo EF02

        # Creating ESP partition
        echo n
        echo 2
        echo
        echo "+${esp_partition_size}"
        echo EF00

        # Creating (optional) Swap partition
        if [[ ! -z $swap_partition_size ]]; then
            echo n
            echo 4
            echo
            echo "+${swap_partition_size}"
            echo 8200
        fi


        # Creating Linux partition
        echo n
        echo 3
        echo
        if [[ ! -z $root_partition_size ]]; then
            echo "+${root_partition_size}"
        else 
            echo
        fi
        echo 8300

        echo p
        if [ $2 ]; then
            echo w
        fi
    ) | gdisk $1
}

function listBlockDevices() {
    lsblk -no kname
}
