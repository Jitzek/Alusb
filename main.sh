#!/bin/bash

_DIR_MAIN=$(dirname ${0})

_INSTALLATION_MIN="${_DIR_MAIN}/lib/install-min/install-script-min.sh"
_INSTALLATION_DWM="${_DIR_MAIN}/lib/install-dwm/install-script-dwm.sh"

source "${_DIR_MAIN}/lib/prompt.sh"
source $_INSTALLATION_MIN
source $_INSTALLATION_DWM

order=( $_INSTALLATION_MIN $_INSTALLATION_DWM )
declare -A installations=(
    [$_INSTALLATION_MIN]="Minimal (Will always be installed)"
    [$_INSTALLATION_DWM]="DWM"
)

clear
printf "Select an installation:\n\n"

while true;

    i=1
    for key in "${order[@]}"; do
        echo "$((i++)): ${installations[$key]}" 
    done

    read installation_selection

    if [ -z $installation_selection ]; then
        printf "Input was empty\n"
        continue
    fi

    if ! [[ "$installation_selection" =~ ^[0-9]+$ ]]; then
        printf "Input was not a number\n"
        continue
	fi

    if [[ $installation_selection -lt 1 ]] || [[ $installation_selection -gt ${#installations[@]} ]]; then
        printf "Chosen installation does not exist \n"
        continue
    fi

    break
done

