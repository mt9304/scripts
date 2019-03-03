#!bin/bash

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

# Setup folders
mkdir -p custdata/WFF_a1a esldata/WFF_a1a custdata/WFF_b2b esldata/WFF_b2b;
# Bi-weekly load folder structure
#mkdir custdata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};
mkdir esldata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};

list_of_term_reasons=(
    Attendance Behaviour Performance Conflict Retirement BetterOffer Unhappy Other
    );

current_dir=$('pwd')
cd esldata/WFF_a1a

for d in */
do
    # Generate random hire and term events
    how_many_to_be_termed=$((1 + RANDOM % 10))
    how_many_to_be_hired=$((1 + RANDOM % 10))
    already_termed=(1 2 3);
    current_event_date=${d}
    current_hire_reason=
    current_term_reason=

    echo 'Terminating '${how_many_to_be_termed}' employees for '${d}

    for i in $(seq 1 $how_many_to_be_termed)
    do

        employee_to_be_termed=$(shuf -i 51244-51341 -n 1)
        employee_to_be_termed=4
        if [ $(array_contains already_termed ${employee_to_be_termed} && echo yes || echo no) = 'no' ]; then
            current_term_reason=${list_of_term_reasons[$((0 + RANDOM % 7))]}
            echo 'Terminating '${employee_to_be_termed}' for reason of '${current_term_reason}
                     # Date       | Employee ID             | Event Date                       | Term Reason
            echo $(basename ${d})\|${employee_to_be_termed}\|$(basename ${current_event_date})\|${current_term_reason} >> term_events_.txt
            already_termed+=(${employee_to_be_termed})
        else
            echo 'Employee already termed'
        fi
    done

    mv term_events_.txt ${d}term_events_$(basename ${d}).txt
    echo 'FiscalMonth\|EventDate\|EmployeeID\|TermEvent' > term_events_.txt
done

# Date         | Employee ID         | Event Date          | Hire Reason
cat <<EOF >> hire_events_.txt
${current_date}|${current_employeeid}|${current_event_date}|current_hire_reason
EOF

cd ${current_dir}