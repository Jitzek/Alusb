########################################
###      Configurable variables      ###
########################################
partition_mbr="/dev/vda1"
partition_gpt="/dev/vda2"
partition_root="/dev/vda3"
partition_home="/dev/vda4"
partition_swap="/dev/vda5"

block_device_mbr="/dev/vda"
block_device_gpt="/dev/vda"
block_device_swap="/dev/vda"
block_device_root="/dev/vda"
block_device_home="/dev/vda"

partition_number_mbr="1"
partition_number_gpt="2"
partition_number_swap="3"
partition_number_root="4"
partition_number_home="5"

## If false, user will not be prompted for creation of mbr and gpt partitions
create_boot_partitions=true
partition_scheme_mbr="10MB"
partition_scheme_gpt="500MB"
## Leave empty to not create swap
partition_scheme_swap=""
## Leave empty for max available size
partition_scheme_root=""
## Leave empty for max available size
partition_scheme_home=""
## If false, user will not be prompted for creation of home partition
create_home_partition=true
## If false, home partition will not be encrypted (user will be prompted)
encrypt_home_partition=false
########################################
###   ENDOF Configurable variables   ###
########################################