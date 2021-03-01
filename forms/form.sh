#% form
#+ form STEPS:array[function] ALLOW_PREV:boolean
#% DESCRIPTION 
#%  Executes given array of functions in sequential order
#%  If a function returns false it will return to the previous function
#%  If there are no previous functions, the form will be exited
function formWithPrev() {
    prev=":prev"

    steps=("$@")

    for (( i=0; i <= ${#steps[@]}; i++ )) do
        if [ $i -lt 0 ]; then
            false
            return
        fi
        printf "\n"
        printf 'Type "%s" to return to the previous step (any other input will continue the form) ' "$prev"
        read uprev
        printf "\n"
        if [[ ! -z $uprev ]] & [[ $uprev == $prev ]]; then
            i=$i-2
            continue
        fi
        if ! ${steps[$i]}; then
            i=$i-2
            continue
        fi
    done
    true
    return
}

function formWithoutPrev() {
    prev=":prev"

    steps=("$@")

    for (( i=0; i <= ${#steps[@]}; i++ )) do
        if [ $i -lt 0 ]; then
            false
            return
        fi
        if ! ${steps[$i]}; then
            i=$i-2
            continue
        fi
    done
    true
    return
}