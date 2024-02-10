#!/bin/bash

########################################
###      Configurable variables      ###
########################################
home_dir=""
BASE_PACKAGES=("gnome" "gnome-tweaks" "thunar" "thunar-archive-plugin" "git" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack" "network-manager-applet" "pavucontrol" "file-roller" "appstream-glib" "wget")
ADDITIONAL_YAY_PACKAGES=("pamac-flatpak-gnome" "ttf-liberation" "downgrade" "mugshot" "update-grub" "gdm-settings")
ADDITIONAL_PACMAN_PACKAGES=("xfce4-terminal" "firefox" "file-roller" "gvfs" "catfish" "xed" "neofetch" "gparted" "firejail" "avahi" "cups" "cups-filters" "cups-pdf" "ghostscript" "gsfonts" "system-config-printer" "w3m" "conky" "conky-manager" "lm_sensors")
TO_REMOVE_PACMAN_PACKAGES=("nautilus" "gnome-console")
########################################
###   ENDOF Configurable variables   ###
########################################