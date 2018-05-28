import os
import fnmatch
import re

#This script finds out which files within a folder (and its children) contain a certain header name. 

print "What is the header name you are trying to find?";
header_name = raw_input();
delimiter = "";

print "What is the folder's name?";
folder_to_search = raw_input();

def get_delimiter():
    print "What is the file delimited by? Options: Tab Pipe Comma";
    global delimiter;
    delimiter = raw_input().lower();
    if delimiter == "tab":
        delimiter = "\t";
    elif delimiter == "pipe":
        delimiter = "|";
    elif delimiter == "comma":
        delimiter = ",";
    elif delimiter == "space":
        delimiter = " ";
    else:
        print "Please choose from the following choices: tab pipe comma";
        get_delimiter();

def find_name_in_header(header_line, file_path):
    file_header_names = header_line.split(delimiter);
    #print file_header_names;
    for name in file_header_names:
        if header_name.lower() in name.lower():
            print "Found in: " + file_path;


def read_all_files_in_folders():
    for root, dirs, files in os.walk(folder_to_search+'/'):
         for file in files:
            with open(os.path.join(root, file), "r") as auto:
                header_line = auto.readline();
                file_path = os.path.join(root, file);
                find_name_in_header(header_line, file_path);
                #print header_line;

get_delimiter();
read_all_files_in_folders();
raw_input();