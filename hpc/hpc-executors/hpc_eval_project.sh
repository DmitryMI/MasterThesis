#!/bin/bash

source "./setvars_hpc.sh"
source "./setvars.sh"
source "./hpc/setvars.sh"

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR is not set!"
    exit 1
else
    echo "CODEBASE_DIR = $CODEBASE_DIR"
fi

cd $SINGULARITY_WORKSPACE_MNT/MasterThesis/stats/
source "./setvars.sh"

if [ -z "$BEEGFS_WORKSPACE" ]
then
    echo "BEEGFS_WORKSPACE not defined!"
    exit 1
fi

PATH_TO_RAW="$BEEGFS_WORKSPACE/omnetpp-results"
source "./run-stats.sh" -c
