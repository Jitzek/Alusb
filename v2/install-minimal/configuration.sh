## CRITICAL INFORMATION WILL BE PROMPTED FOR

########################
###   Partitioning   ###
########################
## The Block device Linux should be installed on
## use commands like `fdisk -l` or `lsblk` to get a list of available devices
block_device=""

## The partitions and their size
## Leave size empty for maximum available space
partition_scheme["mbr"]="10MB"
partition_scheme["esp"]="500MB"
partition_scheme["ext4"]=""
# partition_scheme["swap"]=""


########################
###   Base Install   ###
########################
## Packages to be installed on the new system
base_packages=("base", "linux", "linux-firmware")


################################
###   System Configuration   ###
################################
## Region (used for setting timezone)
region=""

## City (used for setting timezone)
city=""

## Locale
locale="en_US.UTF-8 UTF-8"

## Hostname of the system
hostname=""

## Additional packages (Default: packages for internet connection, basic open source video drivers, notebook touchpad support and battery charge/rate information)
additional_packages=("networkmanager" "xf86-video-ati", "xf86-video-intel", "xf86-video-nouveau", "xf86-video-vesa", "xf86-input-synaptics", "acpi", "sudo")

## Root password
root_passwd=""

## New user
user_name=""

## New user's password
user_passwd=""

## Allow new user access to sudo
give_user_sudo_access=true