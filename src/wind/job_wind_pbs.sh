#!/bin/bash

#PBS -N tephra_wind
#PBS -l mem=4000MB
#PBS -l walltime=336:00:00
#PBS -t 12-21

umask 777
module load languages/anaconda3/ ## change as necessary, python with CDSAPI, NetCDF4, csv
cd $PBS_O_WORKDIR

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo PBS job ID is $PBS_JOBID
echo This job runs on the following machines:
echo $PBS_NODEFILE

YEAR=$(($PBS_ARRAYID+2000))
python wind.py $YEAR

echo Finish time is `date`
