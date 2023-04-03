#!/bin/bash

source "~/scripts/setvars_hpc.sh"
source "~/scripts/hpc/setvars.sh"

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR is not set!"
    exit 1
fi


source "$CODEBASE_DIR/MasterThesis/stats/setvars.sh"

source "$CODEBASE_DIR/MasterThesis/stats/run-stats.sh" -c
