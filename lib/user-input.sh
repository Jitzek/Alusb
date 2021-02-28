#!/bin/bash

export -f confirmByUser

function confirmByUser() {
    read -p "Y/y/N/n" yn

    valid_input=('Y' 'y' 'N' 'n')
    while [[ " ${valid_input[@]} " =~ " ${yn} " ]]; do
        printf "Y/y/N/n expected\n"
        read -p "Y/y/N/n: " yn
    done
    if [[ $yn == 'N' ]] || [[ $yn == 'n' ]]; then
        return false
    fi
    return true
}