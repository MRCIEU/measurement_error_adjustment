#!/bin/bash

#SBATCH --job-name=graphs
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=2000M
#SBATCH --output output-check
#SBATCH --error  errors-check

echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

module load apps/stata/16

echo Run graphs.do $(date)
stata -b graphs.do

echo End Time:$(date)


