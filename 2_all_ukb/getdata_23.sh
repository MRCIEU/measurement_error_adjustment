#!/bin/bash

#SBATCH --job-name=getdata_23
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=700M
#SBATCH --output getdata_23_log
#SBATCH --error  getdata_23_err

echo Start Time:$(date)

#getdata_23.sh - Extracts required variables from UK Biobank file 
#Requires - fields23a.txt, fields23b.txt and fields23c.txt in RESULTS folder, ukbdata_new.txt in DATA folder
#Main output - mainfile23a.txt, mainfile23b.txt and mainfile23c.txt in RESULTS folder

echo 'getdata_23.sh'
cd /user/work/kd18661/meas_error/results
echo Getdata23 $(date)
echo Get list of the variable names and their column positions
head -n 1 /user/work/kd18661/meas_error/data/ukbdata_new.txt | sed 's/\t/\n/g' > header23.txt
awk '{print NR "\t" $s}' header23.txt > headerfinal23.txt

echo File 23a $(date)
echo Keep only the 16th column fieldcode and remove first obs titles
cut -f16 fields23a.txt | sed '1d' > fieldcodes23a.txt
echo Select the columns that match our variable list
cat /user/work/kd18661/meas_error/data/ukbdata_new.txt | cut -f1,$(grep -wFf fieldcodes23a.txt headerfinal23.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > mainfile23a.txt
echo Replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values
sed -i '1s/\./_/g' mainfile23a.txt
sed -i -e 's/\"//g' -e 's/NA//g' mainfile23a.txt
echo Count of columns incl eid
awk -F '\t' '{print NF; exit}' mainfile23a.txt
echo Count of rows incl header
wc -l mainfile23a.txt
echo Number of field ids not instances and arrays
head -n 1 mainfile23a.txt | sed 's/\t/\n/g' | sed 's/_/\t/g' | sed '1d' > mainvars23a.txt
awk '{print $1}' mainvars23a.txt | sort | uniq | wc -l

echo File 23b $(date)
echo Keep only the 16th column fieldcode and remove first obs titles
cut -f16 fields23b.txt | sed '1d' > fieldcodes23b.txt
echo Select the columns that match our variable list
cat /user/work/kd18661/meas_error/data/ukbdata_new.txt | cut -f1,$(grep -wFf fieldcodes23b.txt headerfinal23.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > mainfile23b.txt
echo Replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values
sed -i '1s/\./_/g' mainfile23b.txt
sed -i -e 's/\"//g' -e 's/NA//g' mainfile23b.txt
echo Count of columns incl eid
awk -F '\t' '{print NF; exit}' mainfile23b.txt
echo Count of rows incl header
wc -l mainfile23b.txt
echo Number of field ids not instances and arrays
head -n 1 mainfile23b.txt | sed 's/\t/\n/g' | sed 's/_/\t/g' | sed '1d' > mainvars23b.txt
awk '{print $1}' mainvars23b.txt | sort | uniq | wc -l

echo File 23c $(date)
echo Keep only the 16th column fieldcode and remove first obs titles
cut -f16 fields23c.txt | sed '1d' > fieldcodes23c.txt
echo Select the columns that match our variable list
cat /user/work/kd18661/meas_error/data/ukbdata_new.txt | cut -f1,$(grep -wFf fieldcodes23c.txt headerfinal23.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > mainfile23c.txt
echo Replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values
sed -i '1s/\./_/g' mainfile23c.txt
sed -i -e 's/\"//g' -e 's/NA//g' mainfile23c.txt
echo Count of columns incl eid
awk -F '\t' '{print NF; exit}' mainfile23c.txt
echo Count of rows incl header
wc -l mainfile23c.txt
echo Number of field ids not instances and arrays
head -n 1 mainfile23c.txt | sed 's/\t/\n/g' | sed 's/_/\t/g' | sed '1d' > mainvars23c.txt
awk '{print $1}' mainvars23c.txt | sort | uniq | wc -l

echo End time $(date)
