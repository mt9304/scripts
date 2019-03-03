#!bin/bash

emp_iterator=0
first_emp_id=51243
last_emp_id=51342

for i in $(seq $first_emp_id $last_emp_id)
do
echo 'Generating employee '${emp_iterator}'/99 ('${i}')'
((emp_iterator+=1))
done