#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

results_dir="$CODEBASE_DIR/MasterThesis/drones_veins_project/drones_veins_project/simulation/drones_veins_project/results"

sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:$results_dir ./