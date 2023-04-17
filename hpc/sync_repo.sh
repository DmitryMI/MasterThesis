#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

echo "Invoking clone-repo.sh on HPC..."
echo "cd ./scripts/hpc/hpc-executors/ && source ./clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de

