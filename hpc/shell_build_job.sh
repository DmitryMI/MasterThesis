#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

./sync_executors.sh

echo "BEEGFS_WORKSPACE = $BEEGFS_WORKSPACE"
echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"

#app="singularity exec -H /home/dmmo937c --bind $BEEGFS_WORKSPACE:$SINGULARITY_WORKSPACE_MNT --cpus 1 ubuntu /work/MasterThesis/hpc/singularity-executors/singularity_build_project.sh"

app="singularity exec --bind $BEEGFS_WORKSPACE:$SINGULARITY_WORKSPACE_MNT ./ubuntu /work/MasterThesis/hpc/singularity-executors/singularity_build_project.sh"

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=1 --time=0:10:00 --mem-per-cpu=1024 $app"
echo "cd $BEEGFS_WORKSPACE && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
