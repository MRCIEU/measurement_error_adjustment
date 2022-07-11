#!/bin/bash

#SBATCH --job-name=getdata_01
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2:00:00
#SBATCH --mem=500M
#SBATCH --output getdata_01_log
#SBATCH --error  getdata_01_err

echo Start Time:$(date)

#getdata_01.sh - Extracts required variables from UK Biobank file 
#Requires - fields01.txt in RESULTS folder, ukbdata_new.txt in DATA folder
#Main output - mainfile01.txt in RESULTS folder 

echo 'getdata_01.sh'
cd /user/work/kd18661/meas_error/results
echo "get list of possible variables from main data file (header row)"
head -n 1 /user/work/kd18661/meas_error/data/ukbdata_new.txt | sed 's/\t/\n/g' > header01.txt
awk '{print NR "\t" $s}' header01.txt > headerfinal01.txt

echo "keep only the 16th column (fieldcode) and remove first obs (titles)"
cut -f16 fields01.txt | sed '1d' > fieldcodes01.txt

echo "select the columns that match our variable list"
cat /user/work/kd18661/meas_error/data/ukbdata_new.txt | cut -f1,$(grep -wFf fieldcodes01.txt headerfinal01.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > mainfile01.txt

echo "need to replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values"
sed -i '1s/\./_/g' mainfile01.txt
sed -i -e 's/\"//g' -e 's/NA//g' mainfile01.txt

echo "count of columns (incl eid)"
awk -F '\t' '{print NF; exit}' mainfile01.txt

echo "count of rows (incl header)"
wc -l mainfile01.txt

echo "check number of field ids (not instances and arrays) to check we have data for all"
head -n 1 mainfile01.txt | sed 's/\t/\n/g' | sed 's/_/\t/g' | sed '1d' > mainvars01.txt
awk '{print $1}' mainvars01.txt | sort | uniq | wc -l

echo End Time:$(date)

