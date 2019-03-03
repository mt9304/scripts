#!bin/bash

rand=3

for i in $(seq 1 $rand)
do
    employee_to_be_termed=$(shuf -i 1-100 -n 1)
    echo ${employee_to_be_termed}
done