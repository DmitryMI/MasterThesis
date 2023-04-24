#!/bin/bash

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "./setvars.sh"
fi

CPUS=1
MEM=8192

./sync_executors.sh

echo "cd ./scripts/hpc/hpc-executors/ && source ./clone_repo.sh && exit" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh dmmo937c@taurus.hrsk.tu-dresden.de
if [ $? != 0 ]
then
    echo "Failed to clone repository"
    exit 1
fi

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"

sshpass -f "$HPC_SSH_PASSWORD_FILE" scp $PYTHON_FILE_TO_SCHEDULE dmmo937c@taurusexport.hrsk.tu-dresden.de:$SCRATCH_WORKSPACE

file_name=$(basename $PYTHON_FILE_TO_SCHEDULE)
app="cd CODEBASE_DIR/stats && ./run-stats.sh -v"

cmd="srun --partition=haswell --ntasks=1 --nodes=1 --cpus-per-task=$CPUS --time=0:30:00 --mem-per-cpu=$MEM $app"
echo "cd $SCRATCH_WORKSPACE && $cmd" | sshpass -f "$HPC_SSH_PASSWORD_FILE" ssh -o LogLevel=error dmmo937c@taurus.hrsk.tu-dresden.de
