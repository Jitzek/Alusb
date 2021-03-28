#!/bin/bash

#% prompt
#% DESCRIPTION
#%
#$ @return  true if user confirmed, false if user denied
function prompt() {
    read -p "Y/n: " yn

    valid_input=('Y' 'y' 'N' 'n')
    while [[ ! " ${valid_input[@]} " =~ " ${yn} " ]]; do
        printf "Y/y/N/n expected\n"
        read -p "Y/n: " yn
    done
    if [[ $yn == 'N' ]] || [[ $yn == 'n' ]]; then
        false
        return
    fi
    true
    return
}