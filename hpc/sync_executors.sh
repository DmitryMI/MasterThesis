#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

echo "mkdir -p scripts/hpc-executors && mkdir -p scripts/hpc/singularity-executors && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de

echo "Uploading executor scripts to HPC home directory..."
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r ./hpc-executors dmmo937c@taurusexport.hrsk.tu-dresden.de:~/scripts/hpc/hpc-executors
if [ $? != 0 ]
then
    echo "Failed to sync hpc-executors!"
    exit 1
fi

sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r ./singularity-executors dmmo937c@taurusexport.hrsk.tu-dresden.de:~/scripts/hpc/singularity-executors
if [ $? != 0 ]
then
    echo "Failed to sync singularity-executors!"
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


