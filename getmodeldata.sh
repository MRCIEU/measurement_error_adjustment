#!/bin/bash

#SBATCH --job-name=getmodeldata
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=400M
#SBATCH --output getmodeldata_log
#SBATCH --error  getmodeldata_err


echo Start Time:$(date)

echo 'getmodeldata.do'

cd /user/work/kd18661/meas_error/results

# get list of variables in file and change to rows and add on row number
head -n 1 /user/work/kd18661/meas_error/data/ukbdata_new.txt | sed 's/\t/\n/g' > /user/work/kd18661/meas_error/data/head.txt
awk '{print NR "\t" $s}' /user/work/kd18661/meas_error/data/head.txt > /user/work/kd18661/meas_error/data/head2.txt


# fill in fields required below, main field is 30710 CRP
# outcome is from 40000 date of death, 40001 primary cause of death, 40007 age at death (and age to calculate survival)
# confounders are 31 sex, 1558 alcohol, 21000 ethnicity, 21001 BMI, 21003 age, 2897/20116/20160/20161 smoking, 
#                 20414/20416 alcohol, 26410/26426/26437 deprivation
cat << EOF > /user/work/kd18661/meas_error/data/examplevars.txt
x31_0_0
x53_0_0
x2897_0_0
x2897_1_0
x1558_0_0
x21000_0_0
x21001_0_0
x21001_1_0
x21003_0_0
x21000_0_0
x20116_0_0
x20116_1_0
x20160_0_0
x20160_1_0
x20161_0_0
x20161_1_0
x20414_0_0
x20416_0_0
x26410_0_0
x26426_0_0
x26427_0_0
x30710_0_0
x30710_1_0
x30710_2_0
x30710_3_0
x40000_0_0
x40001_0_0
x40007_0_0
EOF

cat /user/work/kd18661/meas_error/data/examplevars.txt

echo "select the columns we need, outcome and potential confounders, and change rows into columns"

cat /user/work/kd18661/meas_error/data/ukbdata_new.txt | cut -f1,$(grep -wFf /user/work/kd18661/meas_error/data/examplevars.txt /user/work/kd18661/meas_error/data/head2.txt | cut -f1 | sed ':a;N;$!ba;s/\n/,/g') > /user/work/kd18661/meas_error/results/modelfile.txt

echo "need to replace special characters in first line to use as stata variable names and get rid of NAs and quote marks in values"

sed -i -e 's/\"//g' -e 's/NA//g' /user/work/kd18661/meas_error/results/modelfile.txt


echo "count of columns (incl eid)"

awk -F '\t' '{print NF; exit}' /user/work/kd18661/meas_error/results/modelfile.txt

echo "count of rows (records), incl header"
wc -l /user/work/kd18661/meas_error/results/modelfile.txt

echo End Time:$(date)

