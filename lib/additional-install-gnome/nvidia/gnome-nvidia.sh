#!/bin/bash

function gnome_nvidia() {
    sudo pacman --noconfirm -S "${nvidia_packages[@]}"
    echo 'ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"' | sudo tee /etc/udev/rules.d/70-nvidia.rules
}
