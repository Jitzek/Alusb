#!/bin/bash

_DIR_BASE=$(dirname ${0})
_CHROOT_TEMP="/chroot-tmp"

########################
###       Base       ###
########################
function base_min() {
    mkfs.fat -F32 "${PARTITION_MAP[gpt]}"
    mkfs.ext4 "${PARTITION_MAP[root]}"
    if [ "${encrypt_home_partition}" = true ]; then
        ## Setup LUKS disk encryption for /home
        printf "%s" "${root_password}" | cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat "${PARTITION_MAP[home]}"
        ## Unlock encrypted partition with device mapper to gain access
        ## After unlocking the partition, it will be available at /dev/mapper/home (since we named it "home")
        printf "%s" "${root_password}" | cryptsetup open --type luks "${PARTITION_MAP[home]}" home
        mkfs.ext4 /dev/mapper/home
    else
        mkfs.ext4 "${PARTITION_MAP[home]}"
    fi
    if [ ! -z $PARTITION_SCHEME_MAP[swap] ]; then
        mkswap "${PARTITION_MAP[swap]}"
    fi

    mount "${PARTITION_MAP[root]}" /mnt
    mkdir /mnt/boot
    mkdir /mnt/boot/efi
    if [ "$create_boot_partitions" = true ]; then
        mount "${PARTITION_MAP[mbr]}" /mnt/boot
        mount "${PARTITION_MAP[gpt]}" /mnt/boot/efi
    fi
    mkdir /mnt/home
    if [ "${encrypt_home_partition}" = true ]; then
        mount /dev/mapper/home /mnt/home
    else
        mount "${PARTITION_MAP[home]}" /mnt/home
    fi

    pacstrap /mnt "${BASE_PACKAGES[@]}"
    if [ "${encrypt_home_partition}" = true ]; then
        pacstrap /mnt "${ENCRYPT_PACKAGES[@]}"
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

    $(
        if [[ ! -z "${PARTITION_MAP[home]}" ]] && [ "$encrypt_home_partition" = true ]; then
            echo "echo -e 'home\\t${PARTITION_MAP[home]}' >> /etc/crypttab"
            echo "sed -i \"/GRUB_CMDLINE_LINUX=/c\\GRUB_CMDLINE_LINUX=cryptdevice=$(blkid -s UUID -o value ${PARTITION_MAP[home]}):home\" /etc/default/grub"
            echo "sed -i 's/^HOOKS=(base udev autodetect modconf block/& encrypt/' /etc/mkinitcpio.conf"
        fi
    )
    mkinitcpio -p linux-lts

    grub-install --target=i386-pc --boot-directory /boot ${BLOCK_DEVICE_MAP[mbr]}
    grub-install --target=x86_64-efi --efi-directory /boot/efi --boot-directory /boot --removable
    echo 'GRUB_DISABLE_OS_PROBER=false' | tee --append /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    
    pacman -S ${ADDITIONAL_PACKAGES[@]} --noconfirm

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

    printf "\nInstallation complete!\n"
}
########################
###    ENDOF Base    ###
########################
