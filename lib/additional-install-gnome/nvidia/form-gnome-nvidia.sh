#!/bin/bash

#% form
function form_gnome_nvidia() {
    if [[ ! "$configure_nvidia" = true ]]; then
        printf 'Configure system for NVIDIA drivers? This will only configure parts that can be safely configured without potentially breaking the system\n'
        if prompt; then
            configure_nvidia=true
        fi
    fi
}
