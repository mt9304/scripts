#!/bin/bash

# Setup folders
echo 'Setting up folders..'
mkdir -p custdata/WFF_a1a esldata/WFF_a1a custdata/WFF_b2b esldata/WFF_b2b;
# Bi-weekly load folder structure
#mkdir custdata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};
mkdir esldata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};
# Daily load folder structure
#mkdir custdata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};
#mkdir esldata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};

# Initialize current directories
current_dir=$('pwd')
cd esldata/WFF_a1a
# Arrays of useful words
list_of_names=(
    Olivia Ruby Emily Grace Jessica Chloe Sophie Lily Amelia Evie
    Mia Ella Jack Oliver Thomas Harry Joshua Alfie Charlie Daniel
    Table Chair Cup Spoon Pad Tree Mouse Mango Banana Ginger
    );
# echo ${list_of_names[9]}; to echo an index
list_of_job_titles=(
    TechSupport Sales SoftwareEngineer DataConsultant PeopleManager Designer FinanceGuy ProductManager TechnicalLead HRPerson
    );
list_of_departments=(
    Rocket Software Support Finance Tech
    );
list_of_countries=(
    Canada UnitedStates Mexico Egypt Australia
    );
list_of_ethnicities=(
    Caucasian Asian EastAsian WestAsian NorthAsian SouthAsian NorthEastAsian NorthWestAsian SouthEastAsian SouthWestAsian
    );
list_of_term_reasons=(
    Attendance Behaviour Performance Conflict Retirement BetterOffer Unhappy Other
    );

# Create the files and add headers
cat <<EOF > employee_profile_.txt
FiscalMonth|EmployeeID|LastName|FirstName|JobTitle|Department|Location0|Ethnicity
EOF

cat <<EOF > compensation_.txt
FiscalMonth|EmployeeID|BaseSalary|Currency
EOF

cat <<EOF > hire_events_.txt
FiscalMonth|EventDate|EmployeeID
EOF

cat <<EOF > term_events_.txt
FiscalMonth|EventDate|EmployeeID|TermEvent
EOF

#################################
# START: Generate initial files #
#################################
for i in {51243..51342}
do
current_date=2018-01
current_employeeid=${i}

current_first_name=${list_of_names[$((0 + RANDOM % 29))]}
current_last_name=${list_of_names[$((0 + RANDOM % 29))]}
current_job_title=${list_of_job_titles[$((0 + RANDOM % 9))]}
current_department=${list_of_departments[$((0 + RANDOM % 4))]}
current_location0=${list_of_countries[$((0 + RANDOM % 4))]}
current_ethnicity=${list_of_ethnicities[$((0 + RANDOM % 9))]}

current_base_salary=$((48000 + RANDOM % 85000))

# Date         | Employee ID         | Last Name           | First Name         | Job Title          | Department          | Location0          | Ethnicity
cat <<EOF >> employee_profile_.txt
${current_date}|${current_employeeid}|${current_first_name}|${current_last_name}|${current_job_title}|${current_department}|${current_location0}|${current_ethnicity}
EOF

# Date         | Employee ID         | Base Salary          | Currency
cat <<EOF >> compensation_.txt
${current_date}|${current_employeeid}|${current_base_salary}|USD
EOF
done

###############################
# END: Generate initial files #
###############################

########################################
# START: Generate Hire and Term Events #
########################################

for d in */
do
    # Generate random hire and term events
    how_many_to_be_termed=$((1 + RANDOM % 10))
    how_many_to_be_hired=$((1 + RANDOM % 10))
    already_termed=();
    current_event_date=${d}
    current_hire_reason=
    current_term_reason=

    echo 'Terminating '${how_many_to_be_termed}' employees for '${d}

    for i in $(seq 1 $how_many_to_be_termed)
    do
        employee_to_be_termed=$(shuf -i 51244-51341 -n 1)
        #employee_to_be_termed=$(( ( RANDOM % 51341 )  + 51244 ))
        current_term_reason=${list_of_term_reasons[$((0 + RANDOM % 7))]}
        echo 'Terminating '${employee_to_be_termed}' for reason of '${current_term_reason}
                # Date       | Employee ID            | Event Date          | Term Reason
        echo $(basename ${d})\|${employee_to_be_termed}\|$(basename ${current_event_date})\|${current_term_reason} >> term_events_.txt
        already_termed+=(${employee_to_be_termed})
    done

    mv term_events_.txt ${d}term_events_$(basename ${d}).txt
    echo 'FiscalMonth\|EventDate\|EmployeeID\|TermEvent' > term_events_.txt
done

# Date         | Employee ID         | Event Date          | Hire Reason
cat <<EOF >> hire_events_.txt
${current_date}|${current_employeeid}|${current_event_date}|current_hire_reason
EOF

done

cd ${current_dir}

######################################
# END: Generate Hire and Term Events #
######################################