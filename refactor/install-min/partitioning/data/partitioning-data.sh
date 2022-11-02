########################################
###      Configurable variables      ###
########################################
declare -A PARTITION_MAP
PARTITION_MAP[mbr]="/dev/vda1"
PARTITION_MAP[gpt]="/dev/vda2"
PARTITION_MAP[root]="/dev/vda3"
PARTITION_MAP[home]="/dev/vdb1"
PARTITION_MAP[swap]="/dev/vda4"

## If false, user will not be prompted for creation of mbr and gpt partitions
declare -A PARTITION_SCHEME_MAP
PARTITION_SCHEME_MAP[mbr]="10MB"
PARTITION_SCHEME_MAP[gpt]="500MB"
## Leave empty to not create swap
PARTITION_SCHEME_MAP[swap]=""
## Leave empty for max available size
PARTITION_SCHEME_MAP[root]="20GB"
## Leave empty for max available size
PARTITION_SCHEME_MAP[home]=""
## If false, home partition will not be encrypted (user will be prompted)
encrypt_home_partition=false
########################################
###   ENDOF Configurable variables   ###
########################################

declare -A BLOCK_DEVICE_MAP

declare -A PARTITION_NUMBER_MAP