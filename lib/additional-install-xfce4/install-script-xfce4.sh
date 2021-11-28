function main() {
    ################
    ###   Base   ###
    ################
    pacman --noconfirm -Syu
    pacman --noconfirm -S xorg base-devel
    pacman --noconfirm -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings git
    git clone https://aur.archlinux.org/yay-git.git
    makepkg -si ./yay-git
    yay --noconfirm -Syu pamac-aur
}

main