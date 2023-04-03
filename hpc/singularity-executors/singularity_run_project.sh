#!/bin/bash

cd ~/scripts/hpc/singularity-executors
echo "Running singularity_build_project.sh from $(pwd)."
ls

source "../../setvars_hpc.sh"

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "../setvars.sh"
fi

if [ -z "$JOBS" ]
then    
    JOBS=24
    echo "Variable JOBS not set. Setting to default $JOBS"
fi

while getopts ':hj:c:' OPTION; do

  case "$OPTION" in
    h)
      echo "Usage: $(basename $0) [-h for this help message] [-j number of jobs]"
      exit 1
      ;;

    j)
      JOBS="$OPTARG"
      echo "Using cmd arg -j$JOBS. Will run $JOBS jobs in parallel"
      ;;

  esac

done

cd $SINGULARITY_WORKSPACE_MNT/MasterThesis/drones_veins_project/drones_veins_project/simulation/drones_veins_project/
pwd
ls
$INSTALLATION_DIR_RUNMAKER/runmaker/runmaker4.py -j$JOBS $SINGULARITY_BEEGFS_MNT/runfile.txt
