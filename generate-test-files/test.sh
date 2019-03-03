#!/bin/bash

current_directory=$('pwd')
#cd esldata

#for d in */
#do
#echo ${d}
#done

cd ${current_directory}

already_termed=();
#echo already termed: ${already_termed}

already_termed+=('one')
#echo already termed: ${already_termed[0]}
already_termed+=('two')
#echo already termed: ${already_termed[1]}
already_termed+=('three')
#echo already termed: ${already_termed[2]}

#for a in ${already_termed[@]}
#do
##printf ${a}' '
#done

for d in */
do
    echo $(basename ${d})
done

array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

if [ $(array_contains already_termed "two" && echo yes || echo no) = 'no' ]; then
    echo 'add term'
fi

#array_contains already_termed "two"  && echo yes || echo no
#echo $(array_contains already_termed "twao" && echo yes || echo no)