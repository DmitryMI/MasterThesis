#!/bin/bash


if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

./sync_executors.sh

echo "Updating repository..."

echo "source ~/scripts/hpc/setvars.sh && source ~/scripts/hpc/hpc-executors/clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to clone repository"
    exit 1
fi

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"
echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"

sin_app="/root/scripts/hpc/singularity-executors/singularity_build_project.sh"

app="singularity exec -H ~/:/root --bind $SCRATCH_WORKSPACE:$SINGULARITY_WORKSPACE_MNT:rw  ./ubuntu \"$sin_app\""

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=8 --time=0:10:00 --mem-per-cpu=1024 $app"
echo "cd $SCRATCH_WORKSPACE && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
