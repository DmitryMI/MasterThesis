#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

results_dir="$CODEBASE_DIR/MasterThesis/drones_veins_project/drones_veins_project/simulation/drones_veins_project/results"

echo "rm -rf $results_dir && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh
