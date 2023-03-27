#!/bin/bash

cd ./MasterThesis/hpc/singularity-executors
echo "Running singularity_build_project.sh from $(pwd)."

source "../../setvars_hpc.sh"

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "../setvars.sh"
fi

JOBS=1

while getopts ':hj:c:' OPTION; do

  case "$OPTION" in
    h)
      echo "Usage: $(basename $0) [-h for this help message] [-j number of jobs]"
      exit 1
      ;;

    j)
      JOBS="$OPTARG"
      echo "Will run $JOBS jobs in parallel"
      ;;

  esac

done

$INSTALLATION_DIR_RUNMAKER/runmaker/runmaker4.py -j$JOBS $BEEGFS_WORKSPACE/runfile.txt
