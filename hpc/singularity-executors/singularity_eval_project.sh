#!/bin/bash

source "/root/scripts/setvars_hpc.sh"
source "/root/scripts/hpc/setvars.sh"

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR is not set!"
    exit 1
else
    echo "CODEBASE_DIR = $CODEBASE_DIR"
fi

cd $CODEBASE_DIR/MasterThesis/stats/
source "./setvars.sh"

if [ -z "$SINGULARITY_BEEGFS_MNT" ]
then
    echo "SINGULARITY_BEEGFS_MNT not defined!"
    exit 1
fi

PATH_TO_RAW="$SINGULARITY_BEEGFS_MNT/omnetpp-results"
source "./run-stats.sh" -c
