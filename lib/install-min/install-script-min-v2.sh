#!/bin/bash

_DIR_MIN=$(dirname ${0})
_CHROOT_TEMP="/chroot-tmp"

source "${_DIR_MIN}/../prompt.sh"
source "${_DIR_MIN}/form-rest.sh"
source "${_DIR_MIN}/form-partition.sh"

prerequisites=("reflector")

## Configurable variables ##
partition_mbr=""
partition_gpt=""
partition_root=""
partition_home=""
partition_swap=""

partition_block_device_mbr=""
partition_block_device_gpt=""
partition_block_device_root=""
partition_block_device_home=""
partition_block_device_swap=""

partition_number_mbr=""
partition_number_gpt=""
partition_number_root=""
partition_number_home=""
partition_number_swap=""
## If false, user will not be prompted for creation of mbr and gpt partitions
create_boot_partitions=true
partition_scheme_mbr="10MB"
partition_scheme_gpt="500MB"
## Leave empty to not create swap
partition_scheme_swap=""
## Leave empty for max available size
partition_scheme_root=""
## Leave empty for max available size
partition_scheme_home=""
## If false, user will not be prompted for creation of home partition
create_home_partition=true
## If false, home partition will not be encrypted (user will be prompted)
encrypt_home_partition=false
base_packages=("archlinux-keyring" "base" "base-devel" "cmake" "linux-lts" "linux-firmware" "reflector")
encrypt_packages=("lvm2" "cryptsetup")
region=""
country=""
city=""
locale=""
hostname=""
additional_packages=("networkmanager" "xf86-video-ati" "xf86-video-intel" "xf86-video-nouveau" "xf86-video-vesa" "xf86-input-synaptics" "acpi" "sudo" "man-db" "nano" "git" "bash-completion")
root_password=""
user_name=""
user_password=""

partition_device_mbr=""
give_user_sudo_access=true
partition_device_gpt=""

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ## Fill all user determined variables
    form_partition
    form_rest

    ########################
    ###   Partitioning   ###
    ########################
    gdiskPartition false
    printf "Write to disk?\n"
    if ! prompt; then
        exit 1
    fi
    gdiskPartition true

    mkfs.fat -F32 "${partition_gpt}"
    mkfs.ext4 "${partition_root}"
    if [ "${encrypt_home_partition}" = true ]; then
        ## Setup LUKS disk encryption for /home
        printf "%s" "${root_password}" | cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat "${partition_home}"
        ## Unlock encrypted partition with device mapper to gain access
        ## After unlocking the partition, it will be available at /dev/mapper/home (since we named it "home")
        printf "%s" "${root_password}" | cryptsetup open --type luks "${partition_home}" home
        mkfs.ext4 /dev/mapper/home
    else
        mkfs.ext4 "${partition_home}"
    fi
    if [ ! -z $partition_scheme["swap"] ]; then
        mkswap "${partition_swap}"
    fi

    ########################
    ###   Base Install   ###
    ########################
    mount "${partition_root}" /mnt
    mkdir /mnt/boot
    mkdir /mnt/boot/efi
    if [ "$create_boot_partitions" = true ]; then
        mount "${partition_mbr}" /mnt/boot
        mount "${partition_gpt}" /mnt/boot/efi
    else
        mount "${partition_mbr}" /mnt/boot
        mount "${partition_gpt}" /mnt/boot/efi
    fi
    mkdir /mnt/home
    if [ "${encrypt_home_partition}" = true ]; then
        mount /dev/mapper/home /mnt/home
    else
        mount "${partition_home}" /mnt/home
    fi

    pacstrap /mnt "${base_packages[@]}"
    if [ "${encrypt_home_partition}" = true ]; then
        pacstrap /mnt "${encrypt_packages[@]}"
    fi
    genfstab -U /mnt >>/mnt/etc/fstab

    ################################
    ###   System Configuration   ###
    ################################
    chroot_file="/mnt/chroot.sh"
    echo "#!/bin/bash
    mkdir -p ${_CHROOT_TEMP}
    ln -s /usr/share/zoneinfo/$region/$city /etc/localtime
    hwclock --systohc
    sed -i '/${locale}/s/^#//' /etc/locale.gen
    locale-gen
    echo LANG=$(printf $locale | sed 's/\s.*$//') > /etc/locale.conf
    echo $hostname > /etc/hostname
    echo -e '127.0.0.1\\t\\tlocalhost\\n::1\\t\\t\\tlocalhost\\n127.0.1.1\\t\\t${hostname}.localdomain ${hostname}' >> /etc/hosts
    
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
    sed -i '/Storage=.*/s/^#//' /etc/systemd/journald.conf
    sed -i 's/Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=.*/s/^#//' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=/s/$/16M/' /etc/systemd/journald.conf

    sed -i '/ext4/s/relatime/noatime/' /etc/fstab

    pacman -S os-prober grub efibootmgr --noconfirm

    mkinitcpio -p linux
    $(
        if [ "$create_home_partition" = true ] && [ "$encrypt_home_partition" = true ]; then
            echo "sed -i \"/GRUB_CMDLINE_LINUX=/c\\GRUB_CMDLINE_LINUX=cryptdevice=$(blkid -s UUID -o value ${partition_home}):home\" /etc/default/grub"
            echo "sed -i 's/^HOOKS=(base udev autodetect modconf block/& encrypt/' /etc/mkinitcpio.conf"
        fi
    )
    grub-install --target=i386-pc --boot-directory /boot $partition_block_device_mbr
    grub-install --target=x86_64-efi --efi-directory /boot/efi --boot-directory /boot --removable
    echo 'GRUB_DISABLE_OS_PROBER=false' | tee --append /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    
    pacman -S ${additional_packages[@]} --noconfirm

    echo -e '# Enable tab completion\nif [[ -f /etc/bash_completion ]]; then\n\t/etc/bash_completion\nfi' | tee --append /etc/environment

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
    echo -e \"--save /etc/pacman.d/mirrorlist\n--country ${country}\n--protocol https\n--latest 5\n--sort age\" | tee /etc/xdg/reflector/reflector.conf
    systemctl enable reflector.service reflector.timer
    systemctl start reflector.service reflector.timer
    sed -i '/\[multilib]/s/^#//g' /etc/pacman.conf
    sed -i '/^\[multilib]/{N;s/\n#/\n/}' /etc/pacman.conf
    echo 'kernel.sysrq = 176' | tee --append /etc/sysctl.d/99-sysctl.conf
    echo 'blacklist pcspkr' > /etc/modprobe.d/nobeep.conf
    rm -rf ${_CHROOT_TEMP}
    exit" >$chroot_file

    chmod +x $chroot_file

    ## Execute commands in arch-chroot
    arch-chroot /mnt ./chroot.sh

    rm /mnt/chroot.sh

    umount /mnt/boot/efi /mnt/boot /mnt/home /mnt

    if [ "${encrypt_home_partition}" = true ]; then
        cryptsetup close home
    fi

    echo "Installation complete!"
}

#% gdiskPartition
#+ gdiskPartition WRITE_TO_DISK:boolean
#% DESCRIPTION
#%  Partition disk using gdisk
function gdiskPartition() {
    (
        if [ "${create_boot_partitions}" = true ]; then
            # Creating (optional) MBR partition
            echo n
            echo $partition_number_mbr
            echo ""
            echo "+${partition_scheme_mbr}"
            echo EF02

            if $1; then
                echo p
                echo w
                echo "Y"
            fi
        fi

    ) | gdisk $partition_block_device_mbr
    (
        if [ "${create_boot_partitions}" = true ]; then
            # Creating (optional) GPT partition
            echo n
            echo $partition_number_gpt
            echo ""
            echo "+${partition_scheme_gpt}"
            echo EF00

            if $1; then
                echo p
                echo w
                echo "Y"
            fi
        fi
    ) | gdisk $partition_block_device_gpt

    (
        # Creating (optional) Swap partition
        if [[ ! -z "${partition_scheme_swap}" ]]; then
            echo n
            echo $partition_number_swap
            echo ""
            echo "+${partition_scheme_swap}"
            echo 8200

            if $1; then
                echo p
                echo w
                echo "Y"
            fi
        fi
    ) | gdisk $partition_block_device_swap

    (
        # Creating Root partition
        echo n
        echo $partition_number_root
        echo ""
        if [[ ! -z "${partition_scheme_root}" ]]; then
            echo "+${partition_scheme_root}"
        else
            echo ""
        fi
        echo 8300

        if $1; then
            echo p
            echo w
            echo "Y"
        fi
    ) | gdisk $partition_block_device_root

    (
        if [ "${create_home_partition}" = true ]; then
            # Creating (optional) Home partition
            echo n
            echo $partition_number_home
            echo ""
            if [[ ! -z "${partition_scheme_home}" ]]; then
                echo "+${partition_scheme_home}"
            else
                echo ""
            fi
            ## Linux Home
            echo 8302

            if $1; then
                echo p
                echo w
                echo "Y"
            fi
        fi
    ) | gdisk $partition_block_device_home
}

main
