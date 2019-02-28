#!/bin/bash

current_directory=$('pwd')
cd esldata

for d in */
do
echo ${d}
done

cd ${current_directory}

already_termed=();
echo already termed: ${already_termed}

already_termed+=('one')
echo already termed: ${already_termed[0]}
already_termed+=('two')
echo already termed: ${already_termed[1]}
already_termed+=('three')
echo already termed: ${already_termed[2]}

for a in ${already_termed[@]}
do
printf ${a}' '
done