#!/bin/bash

########################################
###      Configurable variables      ###
########################################
home_dir=""
# TODO
BASE_PACKAGES=("plasma-meta" "plasma-framework5" "sddm" "thunar" "thunar-archive-plugin" "git" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "network-manager-applet" "pavucontrol" "file-roller" "appstream-glib" "wget")
ADDITIONAL_YAY_PACKAGES=("pamac-nosnap" "ttf-liberation" "downgrade" "mugshot" "update-grub")
ADDITIONAL_PACMAN_PACKAGES=("kwrite" "firefox" "file-roller" "gvfs" "catfish" "xed" "neofetch" "gparted" "firejail" "avahi" "cups" "cups-filters" "cups-pdf" "ghostscript" "gsfonts" "system-config-printer" "w3m" "conky" "conky-manager" "lm_sensors" "kde-accessibility-meta" "audiocd-kio" "dragon" "elisa" "ffmpegthumbs" "kdenlive" "kdeconnect" "kdenetwork-filesharing" "kget" "krfb" "ktorrent" "kde-system-meta" "kde-utilities-meta")
TO_REMOVE_PACMAN_PACKAGES=()
########################################
###   ENDOF Configurable variables   ###
########################################