#!/bin/bash

source "./lib/user-input.sh"
source "./lib/partitioning.sh"
source "./forms/form.sh"
source "./forms/partition-disk-form.sh"

function main() {

    clear

    if ! form "Alusb" ${(partitionDiskForm installBaseForm configureSystemForm)[@]}; then   
        printf "Exiting Script...\n"
        exit 1
    fi

    # Partition Disk
    # if ! askForSkip "Step 1: Partitioning Disk"; then
    #     partitionDiskForm
    # fi

    # # Install Base Package Set
    # if ! askForSkip "Step 2: Installing Base Package Set"; then
    #     installBaseForm
    # fi

    # # Configuring New System
    # if ! askForSkip "Step 3: Configuring New System"; then
    #     configureSystemForm
    # fi

    exit 0
}

function askForSkip() {
    mskip=":skip"
    printf '%s, skip this step by typing "%s"\n' "$1" "$mskip"
    read mInput
    if [[ mInput == "$mskip" ]]; then
        true
        return
    fi
    false
    return
}

main