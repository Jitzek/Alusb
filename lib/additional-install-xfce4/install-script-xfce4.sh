function main() {
    ################
    ###   Base   ###
    ################
    sudo pacman --noconfirm -Syu
    sudo pacman --noconfirm -S xorg base-devel
    sudo pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings git
    git clone https://aur.archlinux.org/yay-git.git
    $(cd ./yay-git && makepkg -si --noconfirm)
    yay --noconfirm -Syu pamac-aur
}

main