#!/bin/bash

#% form
function form_gnome() {
    # Guess home directory of user if left empty
    if [[ -z "$home_dir" ]]; then
        home_dir=/home/$(who am i | awk '{print $1}')
        while true; do
            printf 'Home directory of user: "%s". Is this correct?\n' $home_dir
            if prompt; then
                break
            fi
            read -p "Please insert the name of the user to install for: /home/" user
            home_dir="/home/$user"
        done
    fi
}
