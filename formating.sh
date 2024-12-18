#!/bin/bash
DATA_MET="hystreet_fussgaengerfrequenzen_seit2021.csv"
DATA_AC="roadtrafficaccidentlocations_2022_20223_withDates.csv"

#check if data exist and create copies to work with.
if [ -e "$DATA_MET" -a -e "$DATA_AC" ]; then
    echo "Both files exits"
    cp  $DATA_MET meterologycopy.csv
    cp  $DATA_AC accidentscopy.csv
else
    exit
fi


#This part will separate first date-time column in meterology data into two columns with headers date and time
awk -F',' 'NR == 1 {
    split($1, a, "T");
    print "Date," substr($0, index($0, $1));
    next;
}
#first part for header, seconde for the rest of the data
{
    split($1, a, "T");
    printf "%s,%s", a[1], a[2];
    for (i = 2; i <= NF; i++) printf ",%s", $i;
    print "";
}' OFS=',' meterologycopy.csv > meterologycopysep.csv
#here we take only first two letters of time to match the accident dataset.
awk -F, 'NR==1 {print; next} {OFS=","; $2=substr($2,1,2); print }' meterologycopysep.csv > meterology_sep.csv
awk -F ',' 'BEGIN {OFS=","} {gsub(/\-/,"/",$1)}1' meterology_sep.csv > output_met.csv


#WE CHANGE ALL THE DOTS IN THE ACCIDENT FILE WITH / TO MATCH WITH OTHER DATA, take first two letters for time
awk -F ',' 'BEGIN {OFS=","} {gsub(/\./,"/",$37)}1' accidentscopy.csv > accidentscopyformatted.csv
#format time
awk -F',' 'NR==1 {print; next} {OFS=","; $36=substr($36,1,2); print }' accidentscopyformatted.csv > output_ac.csv

#here we standardize the time for both datasets as 01-02...
# Input files
dataset1="output_ac.csv"
dataset2="output_met.csv"

# Input and output files

formatted_dataset1="formatted_datasetac.csv"
formatted_dataset2="formatted_datasetmet.csv"

# Initialize output files with headers
head -n 1 "$dataset1" > "$formatted_dataset1"   # Copy header from dataset1
head -n 1 "$dataset2" > "$formatted_dataset2"   # Copy header from dataset2

# Process dataset1 (columns 36 )
awk -F, 'BEGIN { OFS = "," } NR > 1 { # Skip header row
    # Format column 36 as two-digit integers
    $36 = sprintf("%02d", $36)
    # Print the modified row
    print $0
}' "$dataset1" >> "$formatted_dataset1"

# Process dataset2 (column 2)
awk -F, 'BEGIN { OFS = "," } NR > 1 { # Skip header row
    $2 = sprintf("%02d", $2)
    print $0
}' "$dataset2" >> "$formatted_dataset2"

echo "Formatting complete. The formatted files are saved as:"
echo "$formatted_dataset1"
echo "$formatted_dataset2"

rm accidentscopy.csv accidentscopyformatted.csv meterology_sep.csv meterologycopy.csv meterologycopysep.csv