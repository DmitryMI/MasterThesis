#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ ! -f "$CONTAINERS_DIR/$CONTAINER_NAME" ]
then
    echo "Container does not exist. Building on local machine..."
    source ./_singularity_build.sh -f
    if [ $? != 0 ]
    then
        echo "Container building failed."
        exit 1
    fi
fi

./_test_hpc_connection.sh

if [ $? != 0 ]
then
    echo "HPC connection test failed! Is VPN enabled?"
    exit 1
fi

if [ ! -f "$HPC_SSH_PASSWORD_FILE" ]
then
    echo "SSH password file $HPC_SSH_PASSWORD_FILE does not exist!"
    exit -1
else
    echo "Using $HPC_SSH_PASSWORD_FILE as SSH password file."
fi

echo "Uploading hpc-executors scripts to HPC home directory..."
. ./sync_executors.sh

echo "Invoking BeeGFS allocation on HPC..."
echo "source ./setvars.sh && source ./hpc-executors/_setup_hpc_beegfs.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to allocate BeeGFS."
    exit 1
fi

echo "Invoking clone-repo.sh on HPC..."
echo "source ./setvars.sh && source ./hpc-executors/clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to clone repository"
    exit 1
fi

echo "Uploading Slurm scripts to $BEEGFS_WORKSPACE"
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./build.jobfile dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./run.jobfile dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE

if [ $? != 0 ]
then
    echo "Failed to upload Slurm scripts."
    exit 1
fi

echo "Checking if HPC already has Singularity container..."

#remote_query="sha1sum -b $BEEGFS_WORKSPACE/$CONTAINER_NAME | cut -d \" \" -f1"
remote_query="singularity inspect $BEEGFS_WORKSPACE/$CONTAINER_NAME | sha1sum"
remote_query_result=$(echo "$remote_query" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de | tail -n 1)

echo "Remote container-query returned: $remote_query_result"

#local_query_result=$(sha1sum -b $CONTAINERS_DIR/$CONTAINER_NAME  | cut -d " " -f1)
local_query_result=$(singularity inspect $CONTAINERS_DIR/$CONTAINER_NAME | sha1sum)

echo "Local container-query returned: $local_query_result"

if [ "$local_query_result" == "$remote_query_result" ]
then
    echo "HPC has singularity container"
else
    echo "Uploading Singularity container to $BEEGFS_WORKSPACE..."
    # sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $CONTAINERS_DIR/$CONTAINER_NAME dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE
fi


echo "HPC Setup complete: BeeGFS allocated, Singularity container compiled and uploaded, git repository cloned/pulled"
