#!/bin/bash

if [ -z "$SETVARS_GLOBAL_GUARD" ]
then
    echo "Run $(realpath ../setvars.sh) before running this file"
    exit 1
fi

OPP_CONFIG_NAME="Evaluation"
RESULTS_DIR=$(pwd)/results
VEINS_LAUNCHD_PATH="$INSTALLATION_DIR_VEINS/veins/bin/veins_launchd"

RUNSIM_SETVARS_GUARD=1
