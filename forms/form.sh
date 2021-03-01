#% form
#+ form STEPS:array[function]
#% DESCRIPTION 
#%  Executes given array of functions in sequential order
#%  If a function returns false it will return to the previous function
#%  If there are no previous functions, the form will be exited
function form() {
    prev:":prev"

    steps=$1

    for (( i=0; i <= ${#steps[@]}; i++ ))l do
        if [ steps -lt 0 ]; then
            false
            return
        fi
        printf "\n"
        printf 'Type "${prev}" to return to the previous step (any other input will continue the form) ' "$prev"
        read uprev
        if [ $uprev -eq $prev ]; then
            i=$i-2
            continue
        fi
        printf "\n"
        if ! steps[$i]; then
            i=$i-2
            continue
        fi
    done
    true
    return
}