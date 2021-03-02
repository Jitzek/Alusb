#% form
#+ form FORM_NAME:string STEPS:array[function]
#% DESCRIPTION
#%  Executes given array of functions in sequential order
#%  If a function returns false it will return to the previous function
#%  If there are no previous functions, the form will be exited
function form() {
    fprev=":prev"
    fskip=":skip"

    name=$1
    shift
    steps=("$@")

    for ((i = 0; i <= ${#steps[@]} - 1; i++)); do
        clear
        if [ $i -lt 0 ]; then
            false
            return
        fi
        printf "\n"
        printf "%s %s/%s\n" "$name" "$(($i + 1))" "${#steps[@]}"
        printf 'Type "%s" to return to the previous step or type "%s" to skip %s (any other input will continue the form)\n' "$fprev" "$fskip" "$name"
        read fInput
        printf "\n"
        if [[ $fInput == $fprev ]]; then
            # Return to previous step
            i=$i-2
            continue
        fi
        if [[ $fInput == $fskip ]]; then
            # Skip current step
            continue
        fi
        if ! ${steps[$i]}; then
            # Step was canceled, return to previous step
            i=$i-2
            continue
        fi
    done
    true
    return
}
