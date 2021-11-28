#% form
function form_min() {
    ## Block Device not set
    if [[ -z $block_device ]]; then
        while true; do
            block_device=""
            printf "Which block device should Linux be installed on?\n\n"

            lsblk -no kname

            read -p "Please insert the name of the block device: /dev/" block_device
            block_device="/dev/$block_device"
            printf 'Given block device: "%s". Is this correct?\n' $block_device
            if prompt; then
                break
            fi
        done
    fi

    ## MBR partition is empty
    if [[ -z $partition_scheme_mbr ]]; then
        printf "\nMBR partition size is empty\n"
        while true; do
            partition_scheme_mbr="10MB"
            printf "Insert size of MBR partition (default: %s)\n" "$partition_scheme_mbr"
            read partition_scheme_mbr
            if [ -z "$partition_scheme_mbr" ]; then
                printf "Given input is empty\n"
                continue
            fi

            printf "\nAn MBR partition with size ${partition_scheme_mbr} will be created.\n"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    ## GPT partition is empty
    if [[ -z $partition_scheme_gpt ]]; then
        printf "\GPT partition size is empty\n"
        while true; do
            partition_scheme_gpt="500MB"
            printf "Insert size of GPT partition (default: %s)\n" "$partition_scheme_gpt}"
            read partition_scheme_gpt
            if [ -z "$partition_scheme_gpt" ]; then
                printf "Given input was empty\n"
                continue
            fi

            printf "\nAn GPT partition with size ${partition_scheme_gpt} will be created.\n"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    ## Root partition is empty
    if [[ -z $partition_scheme_root ]]; then
        printf "\nRoot partition will use max available size (this will leave no space for a Home partition).\n"
        printf "Confirm?\n"
        if ! prompt; then
            while true; do
                partition_scheme_root=""
                printf "Insert size of Root partition (leave empty for for max available size)\n"
                read partition_scheme_root
                if [ -z "$partition_scheme_root" ]; then
                    printf "\nA Root partition with the max available size will be created (no Home partition will be created).\n"
                else
                    printf "\nA Root partition with size ${partition_scheme_root} will be created.\n"
                fi
                printf "Confirm?\n"
                if ! prompt; then
                    continue
                fi
                break
            done
        fi
    fi

    ## Home partition is empty
    if [[ ! -z $partition_scheme_root ]] && [[ -z $partition_scheme_home ]]; then
        printf "\nHome partition will use max available size\n"
        printf "Confirm?\n"
        if ! prompt; then
            while true; do
                partition_scheme_home=""
                printf "Insert size of Home partition (leave empty for for max available size)\n"
                read partition_scheme_home
                if [ -z "$partition_scheme_home" ]; then
                    printf "\nA Home partition with the max available size will be created.\n"
                else
                    printf "\nA Home partition with size ${partition_scheme_home} will be created.\n"
                fi
                printf "Confirm?\n"
                if ! prompt; then
                    continue
                fi
                break
            done
        fi
    fi

    if [[ -z $region ]]; then
        printf "\nRegion has not been set\n"
        while true; do
            read -p "What Region should be configured? used for configuring timezone: " region
            printf "\n"
            if [[ -z $region ]]; then
                printf "Given input was empty\n"
                continue
            fi
            if ! test -d "/usr/share/zoneinfo/$region"; then
                printf '"/usr/share/zoneinfo/%s" not found\n' "$region"
                continue
            fi

            printf "Region: %s\n" "$region"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $country ]]; then
        printf "\nCountry has not been set\n"
        while true; do
            read -p "What Country should be configured? used for configuring mirrors: " country
            printf "\n"
            if [[ -z $country ]]; then
                printf "Given input was empty\n"
                continue
            fi
            if ! reflector -c "$country"; then
                printf "Country not found\n"
                continue
            fi

            printf "Country: %s\n" "$country"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $city ]]; then
        printf "\nCity has not been set\n"
        while true; do
            read -p "What City should be configured? used for configuring timezone: " city
            printf "\n"
            if [[ -z $city ]]; then
                printf "Given input was empty\n"
                continue
            fi
            if ! test -f "/usr/share/zoneinfo/$region/$city"; then
                printf '"/usr/share/zoneinfo/%s/%s" not found\n' "$region" "$city"
                continue
            fi

            printf "City: %s\n" "$city"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $locale ]]; then
        printf "\nLocale has not been set\n"
        while true; do
            locale="en_US.UTF-8 UTF-8"
            printf "What is your desired locale? (default: %s)\n" "$locale"
            read locale
            if [[ -z $locale ]]; then
                locale="en_US.UTF-8 UTF-8"
                printf "defaulting to %s\n" "$locale"
            fi
            printf "Chosen locale: %s\n" "$locale"
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $hostname ]]; then
        printf "\nHostname has not been set\n"
        while true; do
            hostname=""
            read -p "What is your desired hostname? do not use whitespaces: " hostname
            printf "\n"
            pattern=" |'"
            if [[ -z $hostname ]]; then
                printf "Give input was empty\n"
                continue
            fi
            if [[ $hostname =~ $pattern ]]; then
                printf "Do not use whitespaces\n"
                continue
            fi
            printf "Chosen hostname: %s\n" $hostname
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $root_password ]]; then
        printf "\nRoot password has not been set\n"
        while true; do
            printf "Please supply a valid password with a minimum length of 6\n"
            read -s root_password
            printf "\n"
            if [[ ${#root_password} -lt 6 ]]; then
                continue
            fi
            printf "Confirm password:\n"
            read -s root_password_2
            if [[ $root_password != $root_password_2 ]]; then
                printf "Passwords didn't match\n"
                continue
            fi
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $user_name ]]; then
        user_name=""
        printf "\nNo user name provided\n"
        while true; do
            printf "Create a user?\n"
            if ! prompt; then
                break
            fi
            printf "Please provide a name for the new user\n"
            read user_name
            if [[ -z $user_name ]]; then
                printf "Given input was empty\n"
                continue
            fi
            printf "Chosen username: %s\n" $user_name
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if
        [[ -z $user_password ]] &&
            [[ ! -z $user_name ]]
    then
        printf "\nUser password has not been set\n"
        while true; do
            printf "Please supply a valid password with a minimum length of 6\n"
            read -s user_password
            printf "\n"
            if [[ ${#user_password} -lt 6 ]]; then
                continue
            fi
            printf "Confirm password:\n"
            read -s user_password_2
            if [[ $user_password != $user_password_2 ]]; then
                printf "Passwords didn't match\n"
                continue
            fi
            printf "Confirm?\n"
            if ! prompt; then
                continue
            fi
            break
        done
    fi

    if [[ -z $give_user_sudo_access ]]; then
        printf "Give new user sudo access?\n"
        if prompt; then
            give_user_sudo_access=true
        else
            give_user_sudo_access=false
        fi
    fi
}
