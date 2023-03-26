#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi


echo "Uploading executor scripts to HPC home directory..."
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r ./hpc-executors dmmo937c@taurusexport.hrsk.tu-dresden.de:~/
if [ $? != 0 ]
then
    echo "Failed to sync hpc-executors!"
    exit 1
fi
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r ./singularity-executors dmmo937c@taurusexport.hrsk.tu-dresden.de:~/
if [ $? != 0 ]
then
    echo "Failed to sync singularity-executors!"
    exit 1
fi
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp ./setvars.sh dmmo937c@taurusexport.hrsk.tu-dresden.de:~/
if [ $? != 0 ]
then
    echo "Failed to sync setvars.sh!"
    exit 1
fi

