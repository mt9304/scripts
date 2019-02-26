#!/bin/bash

# Setup folders
#mkdir -p custdata/WFF_a1a esldata/WFF_a1a custdata/WFF_b2b esldata/WFF_b2b;
# Bi-weekly load folder structure
#mkdir custdata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};
#mkdir esldata/WFF_a1a/{20180101,20180201,20180301,20180401,20180501};
# Daily load folder structure
#mkdir custdata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};
#mkdir esldata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};

# Initialize current directories
current_dir=$('pwd')

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

# Create the files and add headers
cat <<EOF > employee_profile_.txt
FiscalMonth|EmployeeID|LastName|FirstName|JobTitle|Department|Location0|Ethnicity
EOF

cat <<EOF > compensation_.txt
FiscalMonth|EmployeeID|BaseSalary|Currency
EOF

cat <<EOF > hire_events_.txt
FiscalMonth|EventDate|EmployeeID|HireReason
EOF

cat <<EOF > term_events_.txt
FiscalMonth|EventDate|EmployeeID|TermEvent
EOF

# For keeping track of termed employees
touch termed_employees.txt

# Appending randomly generated text to files
for i in {51243..51542}
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
current_event_date=
current_hire_reason=
current_term_reason=

should_term_if_50=$((0 + RANDOM % 51))
should_hire_new_if_50=$((0 + RANDOM % 51))

# Date         | Employee ID         | Last Name           | First Name         | Job Title          | Department          | Location0          | Ethnicity
cat <<EOF >> employee_profile_.txt
${current_date}|${current_employeeid}|${current_first_name}|${current_last_name}|${current_job_title}|${current_department}|${current_location0}|${current_ethnicity}
EOF

# Date         | Employee ID         | Base Salary          | Currency
cat <<EOF >> compensation_.txt
${current_date}|${current_employeeid}|${current_base_salary}|USD
EOF

# Date         | Employee ID         | Event Date          | Hire Reason
cat <<EOF >> hire_events_.txt
${current_date}|${current_employeeid}|${current_event_date}|current_hire_reason
EOF

# Date         | Employee ID         | Event Date          | Term Reason
cat <<EOF >> term_events_.txt
${current_date}|${current_employeeid}|${current_event_date}|current_term_reason
EOF
done