#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

CPUS=1

# Out of Memory with 16384 MB on ~30k files!
MEM=1024

# Timeout with 1:00:00 on ~30k files!
TIME="1:00:00"

# ./sync_executors.sh

echo "cd ./scripts/hpc/hpc-executors/ && source ./clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to clone repository"
    exit 1
fi

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"
echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"

# sin_app="/root/scripts/hpc/singularity-executors/singularity_eval_project.sh"
# app="singularity exec -H ~/:/root --bind $SCRATCH_WORKSPACE:$SINGULARITY_WORKSPACE_MNT:rw,$BEEGFS_WORKSPACE:$SINGULARITY_BEEGFS_MNT:rw  ./ubuntu \"$sin_app\""
app="$CODEBASE_DIR/MasterThesis/hpc/hpc-executors/hpc_eval_project.sh"

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=$CPUS --time=$TIME --mem-per-cpu=$MEM $app"
echo "cd $CODEBASE_DIR/MasterThesis/hpc/hpc-executors && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de
# echo "cd $SCRATCH_WORKSPACE && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de
