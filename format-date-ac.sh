#!/bin/bash

FILE=formatted_datasetac.csv

if [ -e "$FILE"  ]; then
    echo " file exits"
else
    exit
fi


# Output files
FORMATTED_FILE1="formatted_fileac.csv"
#check different conditions for possible date formats and standardize them
awk -F, 'BEGIN {OFS=","} 
NR==1 {print; next}  # Print the header without modification
{
    date = $37  # Assuming the date is in the first column
    # Remove leading/trailing whitespaces or carriage returns
    gsub(/^[ \t\r]+|[ \t\r]+$/, "", date)

    # Handle MM/DD/YYYY format
    if (date ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {
        split(date, parts, "/")
        $37 = parts[3] "-" parts[1] "-" parts[2]
    }
    # Handle DD-MM-YYYY format
    else if (date ~ /^[0-9]{2}-[0-9]{2}-[0-9]{4}$/) {
        split(date, parts, "-")
        $37 = parts[3] "-" parts[2] "-" parts[1]
    }
    # Handle DD/MM/YY format (European with 2-digit year)
    else if (date ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{2}$/) {
        split(date, parts, "/")
        year = "20" parts[3]  # Convert 2-digit year to 4-digit year (assuming 20XX)
        $37 = year "-" parts[2] "-" parts[1]  # Convert to YYYY-MM-DD
    }
    # Handle YYYY-MM-DD format
    else if (date ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
    }
    else if (date ~ /^[0-9]{4}\/[0-9]{2}\/[0-9]{2}$/) {
        gsub("/", "-", date)
        $37 = date
    }
    # Handle MM-DD-YYYY format
    else if (date ~ /^[0-9]{2}-[0-9]{2}-[0-9]{4}$/) {
        split(date, parts, "-")
        $37 = parts[3] "-" parts[1] "-" parts[2]
    }
    # Handle DD/MM/YYYY format
    else if (date ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {
        split(date, parts, "/")
        $37 = parts[3] "-" parts[2] "-" parts[1]
    }
    # Handle MMM DD, YYYY format (e.g., Jan 15, 2024)
    else if (date ~ /^[A-Za-z]{3} [0-9]{2}, [0-9]{4}$/) {
        split(date, parts, " ")
        month_name = parts[1]
        day = parts[2]
        year = parts[3]
        # Convert month abbreviation to number
        months["Jan"] = "01"; months["Feb"] = "02"; months["Mar"] = "03"; months["Apr"] = "04";
        months["May"] = "05"; months["Jun"] = "06"; months["Jul"] = "07"; months["Aug"] = "08";
        months["Sep"] = "09"; months["Oct"] = "10"; months["Nov"] = "11"; months["Dec"] = "12";
        month = months[month_name]
        $37 = year "-" month "-" day
    }
    # Handle Month DD, YYYY format (e.g., January 15, 2024)
    else if (date ~ /^[A-Za-z]+ [0-9]{2}, [0-9]{4}$/) {
        split(date, parts, " ")
        month_name = parts[1]
        day = parts[2]
        year = parts[3]
        # Convert full month name to number
        months["January"] = "01"; months["February"] = "02"; months["March"] = "03"; months["April"] = "04";
        months["May"] = "05"; months["June"] = "06"; months["July"] = "07"; months["August"] = "08";
        months["September"] = "09"; months["October"] = "10"; months["November"] = "11"; months["December"] = "12";
        month = months[month_name]
        $37 = year "-" month "-" day
    }
    # Handle YYYY.MM.DD format
    else if (date ~ /^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$/) {
        gsub(/\./, "-", date)
        $37 = date
    }
    # If the date is unrecognized, set it to "INVALID"
    else {
        $37 = "INVALID"
    }
    # Print the modified row
    print
}' $FILE > $FORMATTED_FILE1

rm output_ac.csv formatted_datasetac.csv 