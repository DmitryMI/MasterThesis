#!/bin/bash

cd ~/scripts/hpc/hpc-executors
pwd

if [ -z "$HPC_SETVARS_GUARD" ]
then
    vars=$(realpath "../setvars.sh")
    if [ ! -f "$vars" ]
    then
        echo "$vars does not exist!"
        exit 1
    fi
    source $vars
fi

if [ -z "$BEEGFS_WORKSPACE" ]
then
    echo "BEEGFS_WORKSPACE not defined!"
    exit 1
fi

# validator_path="../stats/scave-validator-vs/"
validator_path="$CODEBASE_DIR/MasterThesis/stats/scave-validator-vs"

$validator_path/ScaveValidator/ScaveValidator.py $validator_path/scave-schema.txt $BEEGFS_WORKSPACE/omnetpp-results -v 1 -o "$BEEGFS_WORKSPACE/ScaveValidator-report.txt "
