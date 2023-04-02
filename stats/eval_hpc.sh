#!/bin/bash

if [ -z "$RUNSIM_SETVARS_GUARD" ]
then
    source "./setvars.sh"
    if [ $? != 0 ]
    then
        echo "Failed to read setvars.sh"
        exit 1
    fi
else
    echo "RUNSIM_SETVARS_GUARD already set to $RUNSIM_SETVARS_GUARD"
fi

source "../hpc/setvars.sh"

echo "Sync job logs..."
cd ../hpc/
source "../hpc/sync_joblogs.sh"
cd ../stats/

echo "Sync raw data..."
rm -rf ./results
source "../hpc/sync_results.sh"

echo "Collecting..."
PATH_TO_RAW="./results"
source ./_collect.sh

echo "Evaluating..."
source ./run-stats.sh -e
