#!/bin/bash

#SBATCH --job-name=boot4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --output outboot4
#SBATCH --error  errboot4


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels4.do'

module load apps/stata/16
stata -b bootmodels4.do

echo End Time:$(date)
