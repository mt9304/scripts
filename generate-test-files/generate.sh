#!/bin/bash

# Setup folders
#mkdir -p custdata/WFF_a1a esldata/WFF_a1a custdata/WFF_b2b esldata/WFF_b2b;
# Bi-weekly load folder structure
#mkdir custdata/WFF_a1a/{20180101,20180115,20180201,20180215,20180301,20180315,20180401,20180415,20180501,20180515};
#mkdir esldata/WFF_a1a/{20180101,20180115,20180201,20180215,20180301,20180315,20180401,20180415,20180501,20180515};
# Daily load folder structure
#mkdir custdata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};
#mkdir esldata/WFF_b2b/{20180101,20180102,20180103,20180104,20180105,20180106,20180107,20180108,20180109,20180110};

# Random list of names
list_of_names=(
    Olivia Ruby Emily Grace Jessica Chloe Sophie Lily Amelia Evie
    Mia Ella Jack Oliver Thomas Harry Jishua Alfie Charlie Daniel
    Table Chair Cup Spoon Mousepad Tree Grass Mango Banana Ginger);
##echo ${list_of_names[9]};

for i in {0..29}
do
echo ${list_of_names[$((0 + RANDOM % 29))]} ${list_of_names[$((0 + RANDOM % 29))]}
done

echo $((0 + RANDOM % 29))