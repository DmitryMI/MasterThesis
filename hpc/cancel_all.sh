#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

echo "scancel --name=build_drones_veins_project && scancel --name=drones_veins_project_run && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
