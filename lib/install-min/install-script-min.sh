#!/bin/bash

_DIR_MIN=$(dirname ${0})
_CHROOT_TEMP="/chroot-tmp"

source "${_DIR_MIN}/../prompt.sh"
source "${_DIR_MIN}/form-min.sh"

prerequisites=("reflector")

partition_number_mbr=1
partition_number_gpt=2
partition_number_root=3
partition_number_home=4
partition_number_swap=5

block_device_ends_with_number=false

partition_suffix_mbr="1"
partition_number_gpt="2"
partition_number_root="3"
partition_number_home="4"
partition_number_swap="5"

## Configurable variables ##
block_device_start=1
block_device=""
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
decrypt_key="secretkey"
base_packages=("base" "base-devel" "cmake" "linux" "linux-firmware" "reflector")
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
give_user_sudo_access=true
partition_device_mbr=""
partition_device_gpt=""

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ## Fill all user determined variables
    form_min

    ########################
    ###   Partitioning   ###
    ########################
    block_device_start=$(($(grep -c "$(echo ${block_device} | cut -c 6-)[0-9]" /proc/partitions) + 1))

    if [ "${create_boot_partitions}" = true ]; then
        partition_number_mbr=$(($block_device_start))
        partition_number_gpt=$(($block_device_start + 1))
        partition_number_root=$(($block_device_start + 2))
        if [ "${create_home_partition}" = true ]; then
            partition_number_home=$(($block_device_start + 3))
            partition_number_swap=$(($block_device_start + 4))
        else
            partition_number_swap=$(($block_device_start + 3))
        fi
    else
        partition_number_root=$(($block_device_start))
        if [ "${create_home_partition}" = true ]; then
            partition_number_home=$(($block_device_start + 1))
            partition_number_swap=$(($block_device_start + 2))
        else
            partition_number_swap=$(($block_device_start + 1))
        fi
    fi
    partition_suffix_mbr=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number_mbr}" || echo "${partition_number_mbr}")
    partition_suffix_gpt=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number_gpt}" || echo "${partition_number_gpt}")
    partition_suffix_root=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number_root}" || echo "${partition_number_root}")
    partition_suffix_home=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number_home}" || echo "${partition_number_home}")
    partition_suffix_swap=$([[ "${block_device_ends_with_number}" = true ]] && echo "p${partition_number_swap}" || echo "${partition_number_swap}")

    gdiskPartition false
    printf "Write to disk?\n"
    if ! prompt; then
        exit 1
    fi
    gdiskPartition true

    mkfs.fat -F32 "${block_device}${partition_suffix_gpt}"
    mkfs.ext4 "${block_device}${partition_suffix_root}"
    if [ "${encrypt_home_partition}" = true ]; then
        ## Setup LUKS disk encryption for /home
        printf "%s" "${root_password}" | cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat "${block_device}${partition_suffix_home}"
        ## Unlock encrypted partition with device mapper to gain access
        ## After unlocking the partition, it will be available at /dev/mapper/home (since we named it "home")
        printf "%s" "${root_password}" | cryptsetup open --type luks "${block_device}${partition_suffix_home}" home
        mkfs.ext4 /dev/mapper/home
        # cryptsetup close home
    else
        mkfs.ext4 "${block_device}${partition_suffix_home}"
    fi
    if [ ! -z $partition_scheme["swap"] ]; then
        mkswap "${block_device}${partition_suffix_swap}"
    fi

    ########################
    ###   Base Install   ###
    ########################
    mount "${block_device}${partition_suffix_root}" /mnt
    mkdir /mnt/boot
    mkdir /mnt/boot/efi
    if [ "$create_boot_partitions" = true ]; then
        mount "${block_device}${partition_suffix_mbr}" /mnt/boot
        mount "${block_device}${partition_suffix_gpt}" /mnt/boot/efi
    else
        mount "${partition_suffix_mbr}" /mnt/boot
        mount "${partition_suffix_gpt}" /mnt/boot/efi
    fi
    mkdir /mnt/home
    if [ "${encrypt_home_partition}" = true ]; then
        mount /dev/mapper/home /mnt/home
    else
        mount "${block_device}${partition_suffix_home}" /mnt/home
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
            # echo "echo -e \"auth \\t optional \\t pam_exec.so expose_authtok /etc/pam_cryptsetup.sh\""
            # echo "sed -i \"/GRUB_ENABLE_CRYPTODISK/c\GRUB_ENABLE_CRYPTODISK=y\" /etc/default/grub"
            echo "sed -i \"/GRUB_CMDLINE_LINUX=/c\\GRUB_CMDLINE_LINUX=cryptdevice=$(blkid -s UUID -o value ${block_device}${partition_suffix_home}):home\" /etc/default/grub"
            echo "sed -i 's/^HOOKS=(base udev autodetect modconf block/& encrypt/' /etc/mkinitcpio.conf"
        fi
    )
    grub-install --target=i386-pc --boot-directory /boot $block_device
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
    rm -rf ${_CHROOT_TEMP}
    exit" >$chroot_file

    chmod +x $chroot_file

    ## Execute commands in arch-chroot
    arch-chroot /mnt ./chroot.sh

    rm /mnt/chroot.sh

    # if [[ ! -z $user_name ]] && [ "$create_home_partition" = true ] && [ "$encrypt_home_partition" = true ]; then
    #     echo -e "auth \t optional \t pam_exec.so expose_authtok /etc/pam_cryptsetup.sh" >>/mnt/etc/pam.d/system-login

    #     pam_cryptsetup_file="/mnt/etc/pam_cryptsetup.sh"
    #     echo "#!/usr/bin/env bash
    #     CRYPT_USER=\"${user_name}\"
    #     PARTITION=\"${block_device}4\"
    #     NAME=\"home-\$CRYPT_USER\"

    #     if [[ \"\$PAM_USER\" == \"\$CRYPT_USER\" && ! -e \"/dev/mapper/\$NAME\" ]]; then
    #         /usr/bin/cryptsetup open \"\$PARTITION\" \"\$NAME\"
    #     fi
    #     " >$pam_cryptsetup_file
    #     chmod +x $pam_cryptsetup_file

    #     uid=$(cat /etc/passwd | grep ${user_name} | cut -d":" -f3)
    #     uid="1000"
    #     echo "
    #     [Unit]
    #     Requires=user@${uid}.service
    #     Before=user@${uid}.service

    #     [Mount]
    #     Where=/home/${user_name}
    #     What=/dev/mapper/home-${user_name}
    #     Type=btrfs
    #     Options=defaults,relatime,compress=zstd

    #     [Install]
    #     RequiredBy=user@${uid}.service
    #     " >"/mnt/etc/systemd/system/home-${user_name}.mount"

    #     dev_partition=$(systemd-escape -p "${block_device}4")
    #     echo "
    #     [Unit]
    #     DefaultDependencies=no
    #     BindsTo=${dev_partition}.device
    #     After=${dev_partition}.device
    #     BindsTo=dev-mapper-home\x2d${user_name}.device
    #     Requires=home-${user_name}.mount
    #     Before=home-${user_name}.mount
    #     Conflicts=umount.target
    #     Before=umount.target

    #     [Service]
    #     Type=oneshot
    #     RemainAfterExit=yes
    #     TimeoutSec=0
    #     ExecStop=/usr/bin/cryptsetup close home-${user_name}

    #     [Install]
    #     RequiredBy=dev-mapper-home\x2d${user_name}.device
    #     " >"/mnt/etc/systemd/system/cryptsetup-${user_name}.service"
    #     ## TODO: https://wiki.archlinux.org/title/Pam_mount
    # fi

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

            # Creating (optional) GPT partition
            echo n
            echo $partition_number_gpt
            echo ""
            echo "+${partition_scheme_gpt}"
            echo EF00
        fi

        # Creating (optional) Swap partition
        if [[ ! -z "${partition_scheme_swap}" ]]; then
            echo n
            echo $partition_number_swap
            echo ""
            echo "+${partition_scheme_swap}"
            echo 8200
        fi

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
        fi

        echo p
        if $1; then
            echo w
            echo "Y"
        fi
    ) | gdisk $block_device
}

main
