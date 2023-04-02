#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ ! -z "$1" ]
then
    JOBFILE_TO_SCHEDULE=$1
fi

if [ -z "$JOBFILE_TO_SCHEDULE" ]
then
    echo "Jobfile not specified!"
    exit 1
fi

./sync_executors.sh

jobfile_name=$(basename $JOBFILE_TO_SCHEDULE)

echo "Uploading Slurm Jobfile to $SCRATCH_WORKSPACE"
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $JOBFILE_TO_SCHEDULE dmmo937c@taurusexport.hrsk.tu-dresden.de:$SCRATCH_WORKSPACE

echo "Invoking remote scheduler..."
sbatch_out=$(echo "cd $SCRATCH_WORKSPACE && sbatch $jobfile_name" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de | tail -n 1)

# Submitted batch job 35160716
SLURM_JOB_ID=$(echo "$sbatch_out" | awk '{print $NF}')

code=$?

echo $sbatch_out

if [[ "$sbatch_out" == *"Submitted"* ]]
then
    echo "OK"
    
    echo $SLURM_JOB_ID
else
    echo "Failed to schedule jobfile"
fi
