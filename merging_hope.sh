#!/bin/bash

FILE1=formatted_filemet.csv
FILE2=formatted_fileac.csv

if [ -e "$FILE1" -a -e "$FILE2"  ]; then
    echo " BOTH file exits"
else
    exit
fi

output_file="merged_accmet.csv"

# Temporary file for storing updated dataset1
temp_file="temp_dataset1.csv"

# Add the header to the output file
header=$(head -n 1 "$FILE2"),weather_condition,temperature
echo "$header" > "$temp_file"

# Process each row of dataset1
tail -n +2 "$FILE2" | while IFS=, read -r line; do
    column37=$(echo "$line" | awk -F',' '{print $37}')
    column36=$(echo "$line" | awk -F',' '{print $36}')
    
    # Find matches in dataset2
    #match1=$(awk -F',' -v value="$column37" '$1 == value {print $7","$8; exit}' "$FILE1")
    #match2=$(awk -F',' -v value="$column36" '$2 == value {print $7","$8; exit}' "$FILE1")
    match=$(awk -F',' -v col37="$column37" -v col36="$column36" '$1 == col37 && $2 == col36 {print $7","$8; exit}' "$FILE1")

    # Take the first match (if exists) or empty
    #new_value=${match1:-$match2}
    #if [[ -n "$match1" ]]; then
    #    new_values="$match1"
    #elif [[ -n "$match2" ]]; then
    #    new_values="$match2"
    #else
    #    new_values="NA"
    #fi
    new_values=${match:-"NA,NA"}
    # Append the new column to the current row
    echo "$line,$new_values" >> "$temp_file"
done

# Move temp file to the output file
mv "$temp_file" "$output_file"

echo "Processing completed. Updated dataset saved in $output_file"
