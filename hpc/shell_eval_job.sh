#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

CPUS=1
MEM=2048

./sync_executors.sh

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"
echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"

sin_app="/root/scripts/hpc/singularity-executors/singularity_eval_project.sh"

app="singularity exec -H ~/:/root --bind $SCRATCH_WORKSPACE:$SINGULARITY_WORKSPACE_MNT:rw,$BEEGFS_WORKSPACE:$SINGULARITY_BEEGFS_MNT:rw  ./ubuntu \"$sin_app\""

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=$CPUS --time=0:10:00 --mem-per-cpu=$MEM $app"
echo "cd $SCRATCH_WORKSPACE && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de
