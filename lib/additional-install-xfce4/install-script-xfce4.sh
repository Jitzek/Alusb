#!/bin/bash

_DIR_XFCE4=$(dirname ${0})
_TEMP_XFCE4=${_DIR_XFCE4}/tmp/
source "${_DIR_XFCE4}/../prompt.sh"
source "${_DIR_XFCE4}/form-xfce4.sh"

## Configurable variables ##
home_dir=""
prerequisites=("")
base_packages=("xorg" "base-devel" "xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings" "git" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "network-manager-applet" "pavucontrol")
# Maybe replace ttf-liberation with official microsoft fonts (see: https://wiki.archlinux.org/title/Microsoft_fonts#Installation)
additional_yay_packages=("pamac-aur" "ttf-liberation" "downgrade" "mugshot" "update-grub") # "openrgb" - takes a long time to install
additional_pacman_packages=("firefox" "firefox-adblock-plus" "file-roller" "gvfs" "catfish" "gedit" "xed" "thunderbird" "neofetch" "gparted" "firejail" "avahi" "cups" "cups-filters" "cups-pdf" "ghostscript" "gsfonts" "system-config-printer" "w3m")
configure_nvidia=false
nvidia_packages=("nvidia-lts" "nvidia-settings")

function main() {
    mkdir ${_TEMP_XFCE4}
    sudo pacman --noconfirm -Syu "${prerequisites[@]}"

    ## Fill all user determined variables
    form_xfce4

    ################
    ###   Base   ###
    ################
    sudo pacman --noconfirm -S "${base_packages[@]}"
    sudo systemctl enable lightdm
    git clone https://aur.archlinux.org/yay-git.git ${_TEMP_XFCE4}/yay/
    $(cd ${_TEMP_XFCE4}/yay && makepkg -si --noconfirm)
    yay --noconfirm -Syu "${additional_yay_packages[@]}"
    sudo pacman --noconfirm -S "${additional_pacman_packages[@]}"
    sudo systemctl enable cups.service
    sudo systemctl enable avahi-daemon.service

    ###################
    ###   Desktop   ###
    ###################
    tar -xvzf "${_DIR_XFCE4}/payloads.tar.gz" -C "${_TEMP_XFCE4}"
    mkdir -p ${home_dir}/.config/xfce4/xfconf
    # Clone Papirus icons
    git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git ${_TEMP_XFCE4}/papirus/
    sudo cp -rf ${_TEMP_XFCE4}/papirus/Papirus /usr/share/icons/
    sudo cp -rf ${_TEMP_XFCE4}/papirus/Papirus-Dark /usr/share/icons/
    sudo cp -rf ${_TEMP_XFCE4}/payloads/usr/share/themes/* /usr/share/themes/
    sudo cp -rf ${_TEMP_XFCE4}/payloads/usr/share/icons/* /usr/share/icons/
    sudo cp -rf ${_TEMP_XFCE4}/payloads/usr/share/backgrounds/* /usr/share/backgrounds/
    sudo cp -rf ${_TEMP_XFCE4}/payloads/etc/lightdm/* /etc/lightdm/
    cp -rf ${_TEMP_XFCE4}/payloads/home/.config/* ${home_dir}/.config/
    cp -rf ${_TEMP_XFCE4}/payloads/home/.bashrc ${home_dir}
    for d in /usr/share/icons/*/; do
        sudo gtk-update-icon-cache "$d"
    done
    # for d in /usr/share/themes/*/; do
    #     sudo gtk-update-icon-cache "$d"
    # done
    # Only 1 theme so no need to loop through all themes
    sudo gtk-update-icon-cache /usr/share/themes/Nordic-darker
    sudo cp -rf ${_TEMP_XFCE4}/payloads/usr/share/gtksourceview-4/styles/* /usr/share/gtksourceview-4/styles/
    mkdir -p ${home_dir}/.local/share/xfce4/terminal/colorschemes/
    cp -rf ${_TEMP_XFCE4}/payloads/home/.local/share/xfce4/terminal/colorschemes/* ${home_dir}/.local/share/xfce4/terminal/colorschemes/

    ###################
    ###   Network   ###
    ###################
    sudo systemctl enable avahi-daemon.service

    ################
    ###   GRUB   ###
    ################
    sudo chmod +x ${_TEMP_XFCE4}/payloads/grub/install.sh
    $(cd ${_TEMP_XFCE4}/payloads/grub && sudo ./install.sh)
    ## For some reason changing the wallpaper (sometimes) causes the grub theme to not work
    # sudo mv /boot/grub/themes/Xenlism-Arch/background.jpg /boot/grub/themes/Xenlism-Arch/background.jpg.bak
    # sudo cp ${_TEMP_XFCE4}/payloads/grub/background.jpg /boot/grub/themes/Xenlism-Arch/background.jpg

    ##################
    ###   Nvidia   ###
    ##################
    if [ "$configure_nvidia" = true ]; then
        sudo pacman --noconfirm -S "${nvidia_packages[@]}"
        echo 'ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"' | sudo tee /etc/udev/rules.d/70-nvidia.rules
        # sudo nvidia-xconfig
    fi

    ####################
    ###   Clean-up   ###
    ####################
    rm -rf ${_TEMP_XFCE4}
}

main
