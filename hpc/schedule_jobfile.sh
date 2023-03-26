#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ -z "$1" ]
then
    echo "Jobfile not specified!"
    exit 1
fi

./sync_executors.sh

jobfile_name=$(basename $1)

echo "Uploading Slurm Jobfile to $BEEGFS_WORKSPACE"
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $1 dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE

echo "Invoking remote scheduler..."
sbatch_out=$(echo "cd $BEEGFS_WORKSPACE && sbatch $jobfile_name" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de | tail -n 1)

echo $sbatch_out

if [[ "$sbatch_out" == *"Submitted"* ]]
then
    echo "OK"
else
    echo "Failed to schedule jobfile"
fi
