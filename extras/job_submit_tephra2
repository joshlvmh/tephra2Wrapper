#!/bin/bash

#SBATCH --job-name tephra2
#SBATCH --partition veryshort
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 2
#SBATCH --time 03:00:00
#SBATCH --mem 100000M

###SBATCH --array=0-14

cd $SLURM_SUBMIT_DIR

#module load apps/matlab/2018a
module load languages/intel/2018-u3
module load tools/git/2.18.0
module load languages/gcc/9.3.0
module load apps/matlab/2018a
module load gc/7.4.4-foss-2016a

options="-nodesktop -noFigureWindows -nosplash"

echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Slurm job IS is $SLURM_JOBID
echo This job runs on the following machines:
echo $SLURM_JOB_NODELIST
echo -e "\n"
echo --------------------- START ---------------------
echo -e "\n"

start=`date +%s`
#matlab $options -r TephraProb_wrapper_JC

./tephra2_2020 inputs/tephra2.conf ../grid/krak.utm  ../wind/gen_files/262000/262000_2012_12_31_18.gen > tephra2_krak_test.out

##mpirun -np 32 -hostfile $SLURM_JOB_NODELIST ./MODEL/tephra2-inversion_2020 ./MODEL/tephra2-inversion-conf_

##chunk=`printf "%02d" $SLURM_ARRAY_TASK_ID`
##srun parallel -j 16 -a T2_stor.txt$chunk
echo -e "\n"
echo --------------------- FINISH ---------------------
echo -e "\n"

echo Finish time is `date`

end=`date +%s`

runtime=`echo "$end - $start" |bc`

function show_time () {
  num=$1
  min=0
  hour=0
  day=0
  sec=0
  if((num>59));then
    ((sec=num%60))
    ((num=num/60))
    if((num>59));then
      ((min=num%60))
      ((num=num/60))
      if((num>23));then
        ((hour=num%24))
        ((day=num/24))
      else
        ((hour=num))
      fi
    else
      ((min=num))
    fi
  else
    ((sec=num))
  fi
  echo "$day"d "$hour"h "$min"m "$sec"s
}

show_time $runtime

#echo Runtime: $runtime

#secs=$runtime
#printf '%dd:%dh:%dm:%ds\n' $((secs/86400)) $((secs%86400/3600)) $((secs%3600/60)) $((secs%60))
