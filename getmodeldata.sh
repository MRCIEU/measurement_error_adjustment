#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=02:00:00
#PBS -o getmodeldata_log
#PBS -e getmodeldata_error
#----------------------------------------

# on compute node, change directory to data directory:
cd $PBS_O_WORKDIR

# set name of job in queue
#PBS -N getmodeldata:

# run your program, timing it for good measure:
# time ./getmodeldata

date 

# get list of variables in file and change to rows and add on row number
head -n 1 ~/meas_error/data/ukbdata.txt | sed 's/\t/\n/g' > ~/meas_error/data/header2.txt
awk '{print NR "\t" $s}' ~/meas_error/data/header2.txt > ~/meas_error/data/headerfinal2.txt


# fill in fields required below, main fields are 3064, 30800 and 100002 
cat << EOF > ~/meas_error/data/examplevars.txt
f.31.0.0
f.21003.0.0
f.21003.1.0
f.30800.0.0
f.30800.1.0
f.40000.0.0
f.40001.0.0
f.40007.0.0
EOF

cat examplevars.txt

echo "select the columns we need, outcome and potential confounders, and change rows into columns"

cat ~/meas_error/data/ukbdata.txt | cut -f1,$(grep -wFf ~/meas_error/data/examplevars.txt ~/meas_error/data/headerfinal.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > ~/meas_error/results/modelfile.txt

echo "need to replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values"

sed -i '1s/\./_/g' ~/meas_error/results/modelfile.txt
sed -i -e 's/\"//g' -e 's/NA//g' ~/meas_error/results/modelfile.txt


echo "count of columns (incl eid)"

awk -F '\t' '{print NF; exit}' ~/meas_error/results/modelfile.txt

echo "count of rows (records), incl header"
wc -l ~/meas_error/results/modelfile.txt

