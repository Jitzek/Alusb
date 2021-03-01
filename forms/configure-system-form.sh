
function configureSystemForm() {
    clear
    if ! form "System Configuration" "${(step1_locale step2_language step3_hostname step4_sudo)[@]}"; then
        false
        return
    fi
    true
    return
}

function step1_locale() {
    while true; do
        printf "Setting Timezone: \n\n"
        printf "Which Region should be configured for this system?\n"
        printf 'Type ":cancel" to exit\n'
        read region
        if [[ -z $region ]]; then
            printf "Region can't be empty"
            continue 
        fi
        if [ $region == ":cancel" ]; then
            false
            return
        fi
        printf "Which City should be configured for this system?\n\n"
        read city
        if [[ -z $city ]]; then
            printf "City can't be empty"
            continue 
        fi
        printf "Region: %s   city: %s" "$region" "$city"
        printf "Is this correct?"
        if ! confirmByUser; then
            continue
        fi

        if ! test -f "/usr/share/zoneinfo/$region"; then
            printf '"/usr/share/zoneinfo/%s" not found\n' "$region"
            continue
        fi
        if ! test -f "/usr/share/zoneinfo/$region/$city"; then
            printf '"/usr/share/zoneinfo/%s/%s" not found\n' "$region" "$city"
            continue
        fi

        ln -s "/usr/share/zoneinfo/$region/$city" /etc/localtime
        if [ ! $? -eq 0 ]; then
            printf "Something went wrong when executing %s\n" "/usr/share/zoneinfo/$region/$city /etc/localtime"
            printf "Try again?\n"
            if ! confirmByUser; then
                false
                return
            fi
            continue
        fi

        hwclock --systohc
        break
    done
    true
    return
}

function step2_language() {
    while true; do
        lang="en_US.UTF-8 UTF-8"
        printf "What is your desired language? Default: %s\n" "$lang"
        printf 'Type ":cancel" to exit\n'
        read lang
        if [[ -z $lang ]]; then
            lang="en_US.UTF-8 UTF-8"
            printf "Defaulting to %s\n" "$lang"
            continue 
        fi
        if [ $lang == ":cancel" ]; then
            false
            return
        fi
        printf "Chosen language: %s'n" "$lang"
        printf "Confirm?\n"
        if ! confirmByUser; then
            continue
        fi

        # Uncomment desired language
        #! TODO

        echo "LANG=$(printf $lang | sed 's/\s.*$//')" > /etc/locale.conf
    done
    true
    return
}

function step3_hostname() {

}

function step4_sudo() {

}