#!/bin/bash

source "./lib/user-input.sh"
source "./lib/partitioning.sh"
source "./forms/form.sh"
source "./forms/partition-disk.sh"

function main() {
    clear
    installFormSteps=(partitionDiskForm)
    if ! form "${installFormSteps}" false; then
        printf "Exiting script..."
        exit
    fi
    printf "Script finished"
    exit
}

main
