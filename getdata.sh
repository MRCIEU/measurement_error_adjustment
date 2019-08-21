#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=02:00:00
#PBS -o output-check
#PBS -e errors-check
#----------------------------------------

# on compute node, change directory to data directory:
cd $PBS_O_WORKDIR

# set name of job in queue
#PBS -N getdata:

# run your program, timing it for good measure:
# time ./getdata

date

echo "this program needs the files fieldcodes.txt and ukbdata.txt"

echo "get list of the variable names and their column positions"

head -n 1 ~/meas_error/data/ukbdata.txt | sed 's/\t/\n/g' > ~/meas_error/data/header.txt

awk '{print NR "\t" $s}' ~/meas_error/data/header.txt > ~/meas_error/data/headerfinal.txt

echo "keep only the 16th column (fieldcode) and remove first obs (titles)"

cut -f16 ~/meas_error/results/fieldcodes.txt | sed '1d' > ~/meas_error/results/fieldcodes2.txt



echo "select the columns that match our variable list"

cat ~/meas_error/data/ukbdata.txt | cut -f1,$(grep -wFf ~/meas_error/results/fieldcodes2.txt ~/meas_error/data/headerfinal.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > ~/meas_error/results/finalfile.txt

echo "need to replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values"

sed -i '1s/\./_/g' ~/meas_error/results/finalfile.txt
sed -i -e 's/\"//g' -e 's/NA//g' ~/meas_error/results/finalfile.txt


echo "count of columns (incl eid)"

awk -F '\t' '{print NF; exit}' ~/meas_error/results/finalfile.txt

echo "count of rows (incl header)"

wc -l ~/meas_error/results/finalfile.txt

echo "check number of field ids (not instances and arrays) to check we have data for all"

head -n 1 ~/meas_error/results/finalfile.txt | sed 's/\t/\n/g' | sed 's/_/\t/g' | sed '1d' > ~/meas_error/results/finalvars.txt
awk '{print $2}' ~/meas_error/results/finalvars.txt | sort | uniq | wc -l

date
