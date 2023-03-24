#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ ! -f "$HPC_SSH_PASSWORD_FILE" ]
then
    echo "SSH password file $HPC_SSH_PASSWORD_FILE does not exist!"
    exit -1
else
    echo "Using $HPC_SSH_PASSWORD_FILE as SSH password file."
fi

echo "Uploading BeeGFS allocation scripts to HPC home directory..."
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./_setup_hpc_beegfs.sh dmmo937c@taurusexport.hrsk.tu-dresden.de:~/
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./setvars.sh dmmo937c@taurusexport.hrsk.tu-dresden.de:~/

echo "Invoking BeeGFS allocation on HPC..."
echo "source ./setvars.sh && source ./_setup_hpc_beegfs.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de

echo "Uploading Slurm scripts to $BEEGFS_WORKSPACE"
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./build.jobfile dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./run.jobfile dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE

if [ $? != 0 ]
then
    echo "Failed to upload Slurm scripts."
    exit 1
fi

if [ ! -f "$CONTAINERS_DIR/$CONTAINER_NAME.sif" ]
then
    echo "Container does not exist. Building on local machine..."
    source ./_singularity_build.sh -f
    if [ $? != 0 ]
    then
        echo "Container building failed."
        exit 1
    fi
fi

echo "Copying Singularity container to $BEEGFS_WORKSPACE"
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $CONTAINERS_DIR/$CONTAINER_NAME.sif dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE

echo "Building drones_veins_project using Singularity container..."
cd $BEEGFS_WORKSPACE
sbatch build.jobfile
