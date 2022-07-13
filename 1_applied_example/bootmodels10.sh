#!/bin/bash

#SBATCH --job-name=boot10
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --output outboot10
#SBATCH --error  errboot10


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels10.do'

module load apps/stata/16
stata -b bootmodels10.do

echo End Time:$(date)
