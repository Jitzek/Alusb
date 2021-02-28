#!/bin/bash

#% confirmByUser
#+ confirmByUser
#% DESCRIPTION
#%
#$ @return  true if user confirmed, false if user denied
function confirmByUser() {
    read -p "Y/y/N/n: " yn

    valid_input=('Y' 'y' 'N' 'n')
    while [[ ! " ${valid_input[@]} " =~ " ${yn} " ]]; do
        printf "Y/y/N/n expected\n"
        read -p "Y/y/N/n: " yn
    done
    if [[ $yn == 'N' ]] || [[ $yn == 'n' ]]; then
        false
        return
    fi
    true
    return
}

function isNumeric() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        true
        return
    fi
    false
    return
}
