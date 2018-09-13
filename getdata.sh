#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=02:00:00
#PBS -o output-check
#PBS -e errors-check
#----------------------------------------

# on compute node, change directory to data directory:
cd $PBS_O_WORKDIR

export $PROJECTDATA="~/meas_error/data"
export $RESULTS="~/meas_error/results"

# set name of job in queue
#PBS -N getdata:

# run your program, timing it for good measure:
# time ./getdata

date

echo "this program needs the files fieldcodes.txt and ukbdata.txt"
echo "change file from comma to tab delimited"

sed 's/,/\t/g' ukbdata.csv > ukbdata.txt

echo "get list of the variable names and their column positions"

head -n 1 $PROJECTDATA/ukbdata.txt | sed 's/\t/\n/g' | sed 's/"//g' > $PROJECTDATA/header.txt

wc -w header.txt
seq 1 13205 > numbers.txt
paste numbers.txt header.txt > headerfinal.txt


echo "keep only the 15th column (fieldcode) and remove first obs (titles)"

dos2unix fieldcodes.txt
cut -f11 fieldcodes.txt > fieldcodes2.txt
sed -i '1d' fieldcodes2.txt

echo "select the columns that match our variable list"
echo "need to replace special characters to use as stata variable names"

cat ukbdata.txt | cut -f1,$(grep -wFf fieldcodes2.txt headerfinal.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g')
sed -i -e '1s/"/v/g' -e '1s/\./_/g' finalfile.txt
sed -i 's/"//g' finalfile.txt

echo "count of columns (incl eid)"

awk -F'\t' '{print NF; exit}' finalfile.txt

echo "count of rows (incl header)"

wc -l finalfile.txt

echo "check number of field ids (not instances and arrays) to check we have data for all
date
