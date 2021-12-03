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
base_packages=("base" "base-devel" "cmake" "linux" "linux-firmware" "reflector" "os-prober" "efibootmgr" "grub")
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

    # mkfs.fat -F32 "${block_device}2"
    ## NOT TESTED
    mkfs.vfat "${block_device}2"
    mkfs.ext4 "${block_device}3"
    mkfs.ext4 "${block_device}4"
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
    mount "${block_device}4" /mnt/home

    pacstrap /mnt "${base_packages[@]}"
    genfstab -U -p /mnt >> /mnt/etc/fstab

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
    echo LANG=$(printf $locale | sed 's/\s.*$//') >/etc/locale.conf
    echo $hostname >/etc/hostname
    echo -e '127.0.0.1\\t\\tlocalhost\\n::1\\t\\t\\tlocalhost\\n127.0.1.1\\t\\t${hostname}.localdomain ${hostname}' >> /etc/hosts
    
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
    sed -i '/Storage=.*/s/^#//' /etc/systemd/journald.conf
    sed -i 's/Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=.*/s/^#//' /etc/systemd/journald.conf
    sed -i '/SystemMaxUse=/s/$/16M/' /etc/systemd/journald.conf

    sed -i '/ext4/s/relatime/noatime/' /etc/fstab

    mkinitcpio -p linux
    grub-install --target=i386-pc --boot-directory=/boot $block_device
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot --removable $block_device
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
    echo '176' > /proc/sys/kernel/sysrq
    git clone https://aur.archlinux.org/yay-git.git ${_CHROOT_TEMP}/yay/
    \$(cd ${_CHROOT_TEMP}/yay && makepkg -si --noconfirm)
    rm -rf ${_CHROOT_TEMP}
    exit" > $chroot_file

    chmod +x $chroot_file

    ## Execute commands in arch-chroot
    arch-chroot /mnt ./chroot.sh

    rm /mnt/chroot.sh

    umount /mnt/boot /mnt

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
            echo 5
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

        # Creating Home partition
        echo n
        echo 4
        echo ""
        if [[ ! -z "${partition_scheme_home}" ]]; then
            echo "+${partition_scheme_home}"
        else
            echo ""
        fi
        echo 8302

        echo p
        if $1; then
            echo w
            echo "Y"
        fi
    ) | gdisk $block_device
}

main
