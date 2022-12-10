#!/bin/bash

function gnome_nvidia() {
    sudo mkdir /etc/pacman.d/hooks
    echo "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-lts

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P" | sudo tee /etc/pacman.d/hooks/nvidia-lts.hook
    sudo pacman --noconfirm -S "${nvidia_packages[@]}"
    echo 'ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"' | sudo tee /etc/udev/rules.d/70-nvidia.rules
    sudo mkinitcpio -P
}
