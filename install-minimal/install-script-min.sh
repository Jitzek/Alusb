#!/bin/bash

source "./lib/form.sh"

## Configurable variables
block_device=""
partition_scheme_mbr="10MB"
partition_scheme_esp="500MB"
partition_scheme_ext4=""
base_packages=("base" "linux" "linux-firmware")
region=""
city=""
locale="en_US.UTF-8 UTF-8"
hostname=""
additional_packages=("networkmanager" "xf86-video-ati" "xf86-video-intel" "xf86-video-nouveau" "xf86-video-vesa" "xf86-input-synaptics" "acpi" "sudo")
root_password=""
user_name=""
user_password=""
give_user_sudo_access=true

function main() {
    ## Fill all user determined variables
    form

    ########################
    ###   Partitioning   ###
    ########################
    gdiskPartition false
    printf "Write to disk?\n"
    if ! prompt; then
        exit 1
    fi
    gdiskPartition true

    mkfs.fat -F32 "${block_device}2"
    mkfs.ext4 "${block_device}3"
    if [ ! -z $partition_scheme["swap"] ]; then
        mkswap "${block_device}4"
    fi

    ########################
    ###   Base Install   ###
    ########################
    pacstrap /mnt "${base_packages[@]}"
    genfstab -U /mnt >>/mnt/etc/fstab

    ################################
    ###   System Configuration   ###
    ################################
    ln -s "/usr/share/zoneinfo/$region/$city" /etc/localtime
    hwclock --systohc

    ## Uncomment desired language
    #! TODO

    echo "LANG=$(printf $lang | sed 's/\s.*$//')" >/etc/locale.conf
}

#% prompt
#% DESCRIPTION
#%
#$ @return  true if user confirmed, false if user denied
function prompt() {
    read -p "Y/n: " yn

    valid_input=('Y' 'y' 'N' 'n')
    while [[ ! " ${valid_input[@]} " =~ " ${yn} " ]]; do
        printf "Y/y/N/n expected\n"
        read -p "Y/n: " yn
    done
    if [[ $yn == 'N' ]] || [[ $yn == 'n' ]]; then
        false
        return
    fi
    true
    return
}

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean
#% DESCRIPTION
#%  Partition disk using gdisk
function gdiskPartition() {
    echo "+${partition_scheme["mbr"]}"
    echo "+${partition_scheme["esp"]}"
    echo "${partition_scheme["ext4"]}"
    exit 0
    (
        # Creating MBR partition
        echo d
        echo n
        echo 1
        echo ""
        echo "+${partition_scheme["mbr"]}"
        echo EF02

        # Creating ESP partition
        echo n
        echo 2
        echo ""
        echo "+${partition_scheme["esp"]}"
        echo EF00

        # Creating (optional) Swap partition
        if [[ ! -z "${partition_scheme["swap"]}" ]]; then
            echo n
            echo 4
            echo ""
            echo "+${partition_scheme["swap"]}"
            echo 8200
        fi

        # Creating Linux partition
        echo n
        echo 3
        echo ""
        if [[ ! -z "${partition_scheme["ext4"]}" ]]; then
            echo "+${partition_scheme["ext4"]}"
        else
            echo ""
        fi
        echo 8300

        echo p
        if [ $1 ]; then
            echo w
        fi
    ) | gdisk $block_device
    if [[ ! -z "${partition_scheme["ext4"]}" ]]; then
        echo "TEST"
    fi
}

main
