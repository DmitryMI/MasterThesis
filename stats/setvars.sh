#!/bin/bash

if [ -z "$SETVARS_GLOBAL_GUARD" ]
then
    global_setvars_path=$(realpath ../setvars.sh)
    echo $global_setvars_path
    if [ -f "$global_setvars_path" ];
    then
        cd ..
        source $global_setvars_path
        cd ./stats
    else
	    echo "Global setvars.sh not found. Some data will not be available."
    fi
else
    echo "SETVARS_GLOBAL_GUARD already set to $SETVARS_GLOBAL_GUARD"
fi

OPP_CONFIG_NAME="Evaluation"
RESULTS_DIR=$(pwd)/results
VEINS_LAUNCHD_PATH="$INSTALLATION_DIR_VEINS/veins/bin/veins_launchd"
MAKE_DIR=$(realpath ../drones_veins_project)

RUNSIM_SETVARS_GUARD=1
