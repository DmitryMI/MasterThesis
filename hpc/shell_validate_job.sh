#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

CPUS=1
MEM=2046

# ./sync_executors.sh

if [ $? != 0 ]
then
    echo "Failed to upload executor scripts!"
    exit 1
fi

echo "cd ./scripts/hpc/hpc-executors/ && source ./clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to clone or pull repository"
    exit 1
fi

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"

# app="~/scripts/hpc/hpc-executors/validate_results.sh"
app="$CODEBASE_DIR/MasterThesis/hpc/hpc-executors/validate_results.sh"

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=$CPUS --time=0:30:00 --mem-per-cpu=$MEM $app"
echo "cd $CODEBASE_DIR/MasterThesis/stats && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de
