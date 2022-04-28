#!/bin/bash

#SBATCH --job-name=runmodels
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=5000M
#SBATCH --output output-check
#SBATCH --error  errors-check


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'runmodels.do'

module load apps/stata/16
stata -b runmodels.do

echo End Time:$(date)
