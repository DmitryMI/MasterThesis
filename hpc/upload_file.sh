#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ -z "$1" ]
then
    echo "Source not specified!"
    exit 1
fi

if [ -z "$2" ]
then
    echo "Destination not specified!"
    exit 1
fi

./_test_hpc_connection.sh

if [ $? != 0 ]
then
    echo "HPC connection test failed! Is VPN enabled?"
    exit 1
fi

echo "Uploading $1 to $2..."
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $1 dmmo937c@taurusexport.hrsk.tu-dresden.de:$2

