#!/bin/bash

if [ -z "$SETVARS_GLOBAL_GUARD" ]
then
    global_setvars_path=$(realpath ../setvars.sh)
    echo $global_setvars_path
    if [ -f "$global_setvars_path" ];
    then
        cd ..
        source $global_setvars_path
        cd ./hpc
    else
	    echo "Global setvars.sh not found. Some data will not be available."
    fi
else
    echo "SETVARS_GLOBAL_GUARD already set to $SETVARS_GLOBAL_GUARD"
fi

if [ -z "$HPC_SETVARS_GUARD" ]
then

    CONTAINERS_DIR="/home/$(whoami)/Software/hpc"
    CONTAINER_NAME="ubuntu"
    BEEGFS_WORKSPACE="/beegfs/ws/0/dmmo937c-drones-workspace"
    SINGULARITY_WORKSPACE_MNT="/mnt"
    BEEGFS_CODEBASE_DIR="$BEEGFS_WORKSPACE"
    HPC_SSH_PASSWORD_FILE="/home/dmitriy/MegaDocuments/TU Dresden Materials/Thesis/Drones/HPC/hpc-ssh-password.txt"

    HPC_SETVARS_GUARD=1
else
    echo "HPC_SETVARS_GUARD already set to $HPC_SETVARS_GUARD"  
fi
