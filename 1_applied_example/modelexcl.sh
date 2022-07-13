#!/bin/bash

#SBATCH --job-name=modelexcl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:15:00
#SBATCH --mem=500M
#SBATCH --output output-check
#SBATCH --error  errors-check


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'modelexcl.do'

module load apps/stata/16
stata -b modelexcl.do

echo End Time:$(date)
