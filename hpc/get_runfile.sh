#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

sshpass -f "$HPC_SSH_PASSWORD_FILE" scp dmmo937c@taurusexport.hrsk.tu-dresden.de:$BEEGFS_WORKSPACE/runfile.txt ./runfile.remote.txt
