#!/bin/bash

source "/root/scripts/setvars_hpc.sh"
source "/root/scripts/hpc/setvars.sh"

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR is not set!"
    exit 1
fi

cd $CODEBASE_DIR/MasterThesis/stats/
source "./setvars.sh"

source "./run-stats.sh" -c
