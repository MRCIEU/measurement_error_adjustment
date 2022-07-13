#!/bin/bash

#SBATCH --job-name=boot7
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --output outboot7
#SBATCH --error  errboot7


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels7.do'

module load apps/stata/16
stata -b bootmodels7.do

echo End Time:$(date)
