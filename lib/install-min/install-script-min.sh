#!/bin/bash

_DIR_MIN=$(dirname ${0})
_CHROOT_TEMP="/chroot-tmp"

source "${_DIR_MIN}/../prompt.sh"
source "${_DIR_MIN}/form-min.sh"

prerequisites=("reflector")

## Configurable variables ##
block_device=""
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

function main() {
    ## Prerequisites
    pacman --noconfirm -S "${prerequisites[@]}"

    ## Fill all user determined variables
    form_min

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
    if [ "${encrypt_home_partition}" = true ]; then
        ## Setup LUKS disk encryption for /home
        cryptsetup -c aes-xts-plain64 -y --use-random luksFormat "${block_device}4"
        ## Unlock encrypted partition with device mapper to gain access
        ## After unlocking the partition, it will be available at /dev/mapper/home (since we named it "home")
        cryptsetup open "${block_device}4" home
        mkfs.ext4 /dev/mapper/home
        cryptsetup close home
    else
        mkfs.ext4 "${block_device}4"
    fi
    if [ ! -z $partition_scheme["swap"] ]; then
        mkswap "${block_device}5"
    fi

    ########################
    ###   Base Install   ###
    ########################
    mount "${block_device}3" /mnt
    mkdir /mnt/boot
    mount "${block_device}2" /mnt/boot
    mkdir /mnt/home
    if [ "${encrypt_home_partition}" = true ]; then
        :
        # mount /dev/mapper/home /mnt/home
    else
        mount "${block_device}4" /mnt/home
    fi

    pacstrap /mnt "${base_packages[@]}"
    if [ "${encrypt_home_partition}" = true ]; then
        pacstrap /mnt "${encrypt_packages[@]}"
    fi
    genfstab -U /mnt >>/mnt/etc/fstab

    ################################
    ###   System Configuration   ###
    ################################
    if [[ ! -z $user_name ]] && [ "$create_home_partition" = true ] && [ "$encrypt_home_partition" = true ]; then
        pam_cryptsetup_file="/mnt/etc/pam_cryptsetup.sh"
        echo "#!/usr/bin/env bash

        CRYPT_USER=\"${user_name}\"
        PARTITION=\"${block_device}4\"
        NAME=\"home-$CRYPT_USER\"

        if [[ \"$PAM_USER\" == \"$CRYPT_USER\" && ! -e \"/dev/mapper/$NAME\" ]]; then
            /usr/bin/cryptsetup open \"$PARTITION\" \"$NAME\"
        fi
        " >$pam_cryptsetup_file
        chmod +x $pam_cryptsetup_file

        uid=$(cat /etc/passwd | grep ${user_name} | cut -d":" -f3)
        echo "
        [Unit]
        Requires=user@${uid}.service
        Before=user@${uid}.service

        [Mount]
        Where=/home/${user_name}
        What=/dev/mapper/home-${user_name}
        Type=btrfs
        Options=defaults,relatime,compress=zstd

        [Install]
        RequiredBy=user@${uid}.service
        " >"/mnt/etc/systemd/system/home-${user_name}.mount"

        dev_partition=$(systemd-escape -p "/dev/${block_device}4")
        echo "
        [Unit]
        DefaultDependencies=no
        BindsTo=${dev_partition}.device
        After=${dev_partition}.device
        BindsTo=dev-mapper-home\x2d${user_name}.device
        Requires=home-${user_name}.mount
        Before=home-${user_name}.mount
        Conflicts=umount.target
        Before=umount.target

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        TimeoutSec=0
        ExecStop=/usr/bin/cryptsetup close home-${user_name}

        [Install]
        RequiredBy=dev-mapper-home\x2d${user_name}.device
        "
        ## TODO: https://wiki.archlinux.org/title/Pam_mount
    fi
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
            echo "echo -e \"auth \\t optional \\t pam_exec.so expose_authtok /etc/pam_cryptsetup.sh\""
            # echo "sed -i \"/GRUB_ENABLE_CRYPTODISK/c\GRUB_ENABLE_CRYPTODISK=y\" /etc/default/grub"
            # echo "sed -i \"/GRUB_CMDLINE_LINUX/c\GRUB_CMDLINE_LINUX=\\"cryptdevice=UUID=\$(blkid -s UUID -o value ${block_device}4):cryptlvm\\"\" /etc/default/grub"
        fi
    )
    grub-install --target=i386-pc --boot-directory /boot $block_device
    grub-install --target=x86_64-efi --efi-directory /boot --boot-directory /boot --removable
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

    umount /mnt/boot /mnt/home /mnt
    cryptsetup close home

    echo "Installation complete!"
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

        # Creating GPT partition
        echo n
        echo 2
        echo ""
        echo "+${partition_scheme_gpt}"
        echo EF00

        # Creating (optional) Swap partition
        if [[ ! -z "${partition_scheme_swap}" ]]; then
            echo n
            if [[ "${create_home_partition}" = true ]]; then
                echo 5
            else
                echo 4
            fi
            echo ""
            echo "+${partition_scheme_swap}"
            echo 8200
        fi

        # Creating Root partition
        echo n
        echo 3
        echo ""
        if [[ ! -z "${partition_scheme_root}" ]]; then
            echo "+${partition_scheme_root}"
        else
            echo ""
        fi
        echo 8300

        # Creating (optional) Home partition
        if [ "${create_home_partition}" = true ]; then
            echo n
            echo 4
            echo ""
            echo "+${partition_scheme_home}"
            # if [ "${encrypt_home_partition}" = true ]; then
            ## Linux LUKS
            # echo 8309
            # else
            ## Linux Home
            echo 8302
            # fi
        fi

        echo p
        if $1; then
            echo w
            echo "Y"
        fi
    ) | gdisk $block_device
}

main
