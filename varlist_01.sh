#!/bin/bash

#SBATCH --job-name=varlist_01
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:10:00
#SBATCH --mem=100M
#SBATCH --output output-check
#SBATCH --error  errors-check

echo Start Time:$(date)

echo 'varlist_01.do'

cd "${SLURM_SUBMIT_DIR}"

module load apps/stata/16
stata -b varlist_01.do 

echo End Time:$(date)
