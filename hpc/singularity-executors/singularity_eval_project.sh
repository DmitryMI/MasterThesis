#!/bin/bash

source "/root/scripts/setvars_hpc.sh"
source "/root/scripts/setvars.sh"
source "/root/scripts/hpc/setvars.sh"

if [ -z "$SINGULARITY_WORKSPACE_MNT" ]
then
    echo "SINGULARITY_WORKSPACE_MNT is not set!"
    exit 1
else
    echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"
fi

cd $SINGULARITY_WORKSPACE_MNT/MasterThesis/stats/
source "./setvars.sh"

if [ -z "$SINGULARITY_BEEGFS_MNT" ]
then
    echo "SINGULARITY_BEEGFS_MNT not defined!"
    exit 1
fi

PATH_TO_RAW="$SINGULARITY_BEEGFS_MNT/omnetpp-results"
source "./run-stats.sh" -c
