#!/bin/bash

#SBATCH --job-name tephra_eps
#SBATCH --partition hmem
#SBATCH --mem=4G
#SBATCH --time 14-00:00:0
#SBATCH --array=2-7


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

YEAR=$(($SLURM_ARRAY_TASK_ID))
python espPlinian.py --esp-csv=VEI${YEAR}.csv

echo Finish time is `date`
