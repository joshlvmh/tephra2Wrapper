#!/bin/bash

#SBATCH --job-name tephra_grid
#SBATCH --partition cpu
#SBATCH --mem=4G
#SBATCH --time 02:00:0

umask 0
module load languages/anaconda3/
cd $SLURM_SUBMIT_DIR
export PYTHONPATH=$HOME/lib/python3.7/site-packages

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Slurm job ID is $SLURM_JOBID
echo This job runs on the following machines:
echo $SLURM_JOB_NODELIST

python grid_gen.py

echo Finish time is `date`
