#!/bin/bash

########################################
###      Configurable variables      ###
########################################
home_dir=""
# TODO
BASE_PACKAGES=("plasma-meta" "sddm" "thunar" "thunar-archive-plugin" "git" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "network-manager-applet" "pavucontrol" "file-roller" "appstream-glib" "wget")
ADDITIONAL_YAY_PACKAGES=("ttf-liberation" "downgrade" "mugshot" "update-grub")
ADDITIONAL_PACMAN_PACKAGES=("kwrite" "firefox" "file-roller" "gvfs" "catfish" "xed" "neofetch" "gparted" "firejail" "avahi" "cups" "cups-filters" "cups-pdf" "ghostscript" "gsfonts" "system-config-printer" "w3m" "conky" "conky-manager" "lm_sensors" "kde-accessibility-meta" "audiocd-kio" "dragon" "elisa" "ffmpegthumbs" "kdenlive" "kdeconnect" "kdenetwork-filesharing" "kget" "krfb" "ktorrent" "kde-system-meta" "ark" "filelight" "isoimagewriter" "kalk" "kbackup" "timeshift" "kcalc" "kcharselect" "kclock" "kdebugsettings" "kdf" "kdialog" "kfind" "kgpg" "konsole" "krecorder" "ktimer" "markdownpart" "skanpage" "sweeper" "yakuake")
TO_REMOVE_PACMAN_PACKAGES=()
########################################
###   ENDOF Configurable variables   ###
########################################