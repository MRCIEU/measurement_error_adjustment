#!/bin/bash

#SBATCH --job-name=boot1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --output outboot1
#SBATCH --error  errboot1


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels1.do'

module load apps/stata/16
stata -b bootmodels1.do

echo End Time:$(date)
