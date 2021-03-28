#!/bin/bash

DIR=`dirname ${0}`

source "${DIR}/lib/form.sh"

## Configurable variables ##
block_device=""
partition_scheme_mbr="10MB"
partition_scheme_esp="500MB"
## Leave empty to not create swap
partition_scheme_swap=""
## Leave empty for max available size
partition_scheme_ext4=""
base_packages=("base" "linux" "linux-firmware")
region=""
city=""
locale=""
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
    mount "${block_device}3" /mnt
    mkdir /mnt/boot
    mount "${block_device}2" /mnt/boot

    pacstrap /mnt "${base_packages[@]}"
    genfstab -U /mnt >>/mnt/etc/fstab

    ################################
    ###   System Configuration   ###
    ################################
    chroot_file="/mnt/chroot.sh"
    echo "#!/bin/bash
    ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
    hwclock --systohc
    sed -i '/${locale}/s/^#//' /etc/locale.gen
    locale-gen
    echo LANG=$(printf $locale | sed 's/\s.*$//') >/etc/locale.conf
    echo $hostname >/etc/hostname
    echo -e '127.0.0.1\\t\\tlocalhost\\n::1\\t\\t\\tlocalhost\\n127.0.1.1\\t\\t${hostname}.localdomain ${hostname}' >> /etc/hosts
    
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
    sed -i '/Storage=.*/s/^#//' /etc/systemd/journald.conf
    sed -i 's/Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=.*/s/^#//' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=/s/$/16M/' /etc/systemd/journald.conf

    sed -i '/ext4/s/relatime/noatime/' /etc/fstab
    
    pacman -S grub efibootmgr --noconfirm
    grub-install --target=i386-pc --boot-directory /boot $block_device
    grub-install --target=x86_64-efi --efi-directory /boot --boot-directory /boot --removable
    grub-mkconfig -o /boot/grub/grub.cfg
    
    pacman -S ${additional_packages[@]} --noconfirm

    echo 'root:${root_password}' | chpasswd

    $(
        if [ ! -z $user_name ]; then
            echo "useradd -m -G wheel -s /bin/bash $user_name"
            echo "echo '${user_name}:${user_password}' | chpasswd"
            if $give_user_sudo_access; then
                echo "sed -i '/^root.*/a ${user_name} ALL=(ALL) ALL' /etc/sudoers"
            fi
        fi
    )
    systemctl enable NetworkManager.service
    exit" > $chroot_file

    chmod +x $chroot_file

    ## Execute commands in arch-chroot
    arch-chroot /mnt ./chroot.sh

    rm /mnt/chroot.sh

    umount /mnt/boot /mnt

    echo "Installation complete!"
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
    (
        # Creating MBR partition
        echo d
        echo n
        echo 1
        echo ""
        echo "+${partition_scheme_mbr}"
        echo EF02

        # Creating ESP partition
        echo n
        echo 2
        echo ""
        echo "+${partition_scheme_esp}"
        echo EF00

        # Creating (optional) Swap partition
        if [[ ! -z "${partition_scheme_swap}" ]]; then
            echo n
            echo 4
            echo ""
            echo "+${partition_scheme_swap}"
            echo 8200
        fi

        # Creating Linux partition
        echo n
        echo 3
        echo ""
        if [[ ! -z "${partition_scheme_ext4}" ]]; then
            echo "+${partition_scheme_ext4}"
        else
            echo ""
        fi
        echo 8300

        echo p
        if $1; then
            echo w
            echo "Y"
        fi
    ) | gdisk $block_device
}

main
