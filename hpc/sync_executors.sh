#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

echo "mkdir -p scripts/hpc && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de

echo "Uploading executor scripts to HPC home directory..."
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r ./ dmmo937c@taurusexport.hrsk.tu-dresden.de:~/scripts/hpc
if [ $? != 0 ]
then
    echo "Failed to sync hpc-executors!"
    exit 1
fi

sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ../setvars.sh dmmo937c@taurusexport.hrsk.tu-dresden.de:~/scripts
if [ $? != 0 ]
then
    echo "Failed to sync setvars.sh!"
    exit 1
fi

sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ../setvars_hpc.sh dmmo937c@taurusexport.hrsk.tu-dresden.de:~/scripts
if [ $? != 0 ]
then
    echo "Failed to sync setvars_hpc.sh!"
    exit 1
fi


