#!bin/bash

grep -v 51321 employee_profile_.txt > temp_employee_profile && mv temp_employee_profile employee_profile_.txt