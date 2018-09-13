#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=02:00:00
#PBS -o output-check
#PBS -e errors-check
#----------------------------------------

# on compute node, change directory to 'submission directory':
cd $PBS_O_WORKDIR

# set name of job in queue
#PBS -N check20:


# run your program, timing it for good measure:
# time ./check20

date

echo "load stata"
module add apps/stata15

echo "running stata do file"
stata -b check20.do

date
