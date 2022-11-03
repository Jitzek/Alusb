#% form
function form_gnome() {
    # Guess home directory of user if left empty
    if [[ -z $home_dir ]]; then
        home_dir=/home/$(who am i | awk '{print $1}')
    fi
    while true; do
        printf 'Home directory of user: "%s". Is this correct?\n' $home_dir
        if prompt; then
            break
        fi
        read -p "Please insert the name of the user to install for: /home/" user
        home_dir="/home/$user"
    done

    if [[ ! "$configure_nvidia" = true ]]; then
        printf 'Configure system for NVIDIA drivers? This will only configure parts that can be safely configured without potentially breaking the system\n'
        if prompt; then
            configure_nvidia=true
        fi
    fi
}
