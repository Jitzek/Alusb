########################################
###      Configurable variables      ###
########################################
declare -A PARTITION_MAP
PARTITION_MAP[mbr]="/dev/vda1"
PARTITION_MAP[gpt]="/dev/vda2"
PARTITION_MAP[root]="/dev/vda3"
PARTITION_MAP[home]=""
PARTITION_MAP[swap]=""

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

declare -A PARTITION_INDEX_MAP
PARTITION_INDEX_MAP[0]="mbr"
PARTITION_INDEX_MAP[1]="gpt"
PARTITION_INDEX_MAP[2]="swap"
PARTITION_INDEX_MAP[3]="root"
PARTITION_INDEX_MAP[4]="home"

declare -A BLOCK_DEVICE_MAP

declare -A PARTITION_NUMBER_MAP

declare -A PARTITION_CODE_MAP
PARTITION_CODE_MAP[mbr]="EF02"
PARTITION_CODE_MAP[gpt]="EF00"
PARTITION_CODE_MAP[swap]="8200"
PARTITION_CODE_MAP[root]="8300"
PARTITION_CODE_MAP[home]="8302"
