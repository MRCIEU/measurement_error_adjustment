#!/bin/bash

#SBATCH --job-name=bootmodels
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=28:00:00
#SBATCH --mem=5000M
#SBATCH --output output-check
#SBATCH --error  errors-check


echo Start Time:$(date)

cd "${SLURM_SUBMIT_DIR}"

echo 'bootmodels.do'

module load apps/stata/16
stata -b bootmodels1.do
stata -b bootmodels2.do
stata -b bootmodels3.do
stata -b bootmodels4.do
stata -b bootmodels5.do

echo End Time:$(date)
