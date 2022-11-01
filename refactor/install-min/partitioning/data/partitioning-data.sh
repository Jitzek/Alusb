########################################
###      Configurable variables      ###
########################################
partition_mbr=""
partition_gpt=""
partition_root=""
partition_home=""
partition_swap=""

block_device_mbr=""
block_device_gpt=""
block_device_swap=""
block_device_root=""
block_device_home=""

partition_number_mbr=""
partition_number_gpt=""
partition_number_swap=""
partition_number_root=""
partition_number_home=""

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