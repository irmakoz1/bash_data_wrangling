#!/bin/bash

# Input files
dataset1="formatted_filemet.csv"
dataset2="formatted_fileac.csv"
log_file="matching_log.txt"  # Log file to track matches

# Initialize the log file
echo "Match Debugging Log - $(date)" > "$log_file"

# Iterate over dataset2 (column 37)
echo "Iterating over dataset2 (column 37)..." >> "$log_file"

# Process dataset2
awk -F, 'NR > 1 {  # Skip header row in dataset2
    col37 = $37;  # Column 37 from dataset2
    print "Checking Dataset2 Col37: " col37 >> "'$log_file'";

    # Iterate over dataset1 (column 1) and check for matches
    while ((getline line < "'$dataset1'") > 0) {
        split(line, arr, ",");
        col1 = arr[1];  # Column 1 from dataset1
        
        # Log the comparison
        print "Dataset2 Col37: " col37 " Checking against Dataset1 Col1: " col1 >> "'$log_file'";
        
        # If a match is found
        if (col37 == col1) {
            print "MATCH FOUND: Dataset2 Col37: " col37 " matched Dataset1 Col1: " col1 >> "'$log_file'";
        }
    }

    # Reset dataset1 pointer for the next value in dataset2
    close("'$dataset1'");
}' "$dataset2"

echo "Match checking completed. Check the log file $log_file for details."
