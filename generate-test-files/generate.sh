#!/bin/bash

# Setup folders
#mkdir -p custdata/WFF_a1a esldata/WFF_a1a custdata/WFF_b2b esldata/WFF_b2b;
# Bi-weekly load folder structure
#mkdir custdata/WFF_a1a/{20180101,20180115,20180201,20180215,20180301,20180315,20180401,20180415,20180501,20180515};
#mkdir esldata/WFF_a1a/{20180101,20180115,20180201,20180215,20180301,20180315,20180401,20180415,20180501,20180515};
# Daily load folder structure
#mkdir custdata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};
#mkdir esldata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};

# Arrays of useful words
list_of_names=(
    Olivia Ruby Emily Grace Jessica Chloe Sophie Lily Amelia Evie
    Mia Ella Jack Oliver Thomas Harry Jishua Alfie Charlie Daniel
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

for i in {0..9}
do
# Date | Last Name                            | First Name                           | Job Title                                | Department                                | BaseSalary                | Location0                               | Ethnicity
cat <<EOF >> test.txt
2018-01|${list_of_names[$((0 + RANDOM % 29))]}|${list_of_names[$((0 + RANDOM % 29))]}|${list_of_job_titles[$((0 + RANDOM % 9))]}|${list_of_departments[$((0 + RANDOM % 4))]}|$((48000 + RANDOM % 85000))|${list_of_countries[$((0 + RANDOM % 4))]}|${list_of_ethnicities[$((0 + RANDOM % 9))]}
EOF
done