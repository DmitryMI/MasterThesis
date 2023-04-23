#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

if [ -z "$CODEBASE_DIR" ]
then
    echo "CODEBASE_DIR not set!"
    exit 1
fi

results_dir="$BEEGFS_WORKSPACE/omnetpp-results"
eval_dir="$CODEBASE_DIR/MasterThesis/stats/eval"

#sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:$results_dir ./
echo "Downloading from $eval_dir to $(pwd)..."
# sshpass -f "$HPC_SSH_PASSWORD_FILE" rsync -r dmmo937c@taurusexport.hrsk.tu-dresden.de:$eval_dir ./
sshpass -f "$HPC_SSH_PASSWORD_FILE" scp -r dmmo937c@taurusexport.hrsk.tu-dresden.de:$eval_dir ./
