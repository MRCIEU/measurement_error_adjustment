#!/bin/bash

#SBATCH --job-name=boot3
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --output outboot3
#SBATCH --error  errboot3


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels3.do'

module load apps/stata/16
stata -b bootmodels3.do

echo End Time:$(date)
