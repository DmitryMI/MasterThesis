#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR
cd $SCRIPT_DIR
echo "wd: $(pwd)"

source "../../setvars_hpc.sh"
source "../../setvars.sh"
source "../setvars.sh"

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR is not set!"
    exit 1
else
    echo "CODEBASE_DIR = $CODEBASE_DIR"
fi

if [ -z "$BEEGFS_WORKSPACE" ]
then
    echo "BEEGFS_WORKSPACE not defined!"
    exit 1
fi

cd $CODEBASE_DIR/MasterThesis/stats/
source "./setvars.sh"

PATH_TO_RAW="$BEEGFS_WORKSPACE/omnetpp-results"
source "./run-stats.sh" -c
