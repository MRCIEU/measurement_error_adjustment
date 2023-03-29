#!/bin/bash

#SBATCH --job-name=rundata_01
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=8:00:00
#SBATCH --mem=8000M
#SBATCH --output output-check
#SBATCH --error  errors-check

echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

module load apps/stata/17

echo Run rundata_01.do $(date)
stata -b rundata_01.do

echo End Time:$(date)


