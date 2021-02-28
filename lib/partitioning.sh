#!/bin/bash

export -f gdiskPartition
export -f listBlockDevices

#% gdiskPartition
#+ gdiskPartition SWAP_SIZE:int SWAP_SIZE_SUFFIX:string WRITE_TO_DISK:boolean
#% DESCRIPTION
#%  Partition disk using gdisk
function gdiskPartition() {
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

function listBlockDevices() {
    lsblk -no kname
}