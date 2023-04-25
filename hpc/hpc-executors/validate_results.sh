#!/bin/bash

cd ~/scripts/hpc/hpc-executors
pwd

if [ -z "$HPC_SETVARS_GUARD" ]
then
    vars=$(realpath "../setvars.sh")
    if [ ! -f "$vars" ]
    then
        echo "$vars does not exist!"
        exit 1
    fi
    source $vars
fi

if [ -z "$BEEGFS_WORKSPACE" ]
then
    echo "BEEGFS_WORKSPACE not defined!"
    exit 1
fi

# validator_path="../stats/scave-validator-vs/"
validator_path="$CODEBASE_DIR/MasterThesis/stats/scave-validator-vs"

# $validator_path/ScaveValidator/ScaveValidator.py $validator_path/scave-schema.txt $BEEGFS_WORKSPACE/omnetpp-results -v 1 -o "$BEEGFS_WORKSPACE/ScaveValidator-report.txt"

if [ $? != 0 ]
then
    echo "ScaveValidator failed!"
    exit 1
fi

hide_dir_exists=0

input="$BEEGFS_WORKSPACE/ScaveValidator-report.txt"
while IFS= read -r failed_file_path
do
    fname=$(basename $failed_file_path)
    fdirpath=$(dirname "$failed_file_path")
    fdirname=$(basename $fdirpath)
    fdirdirpath=$(dirname "$fdirpath")
    hide_dirname="$fdirname-invalid"
    hide_dirpath="$fdirdirpath/$hide_dirname"
    hide_fpath="$hide_dirpath/$fname"
    
    if [ "$hide_dir_exists" == 0 ]
    then
        if [ ! -d "$hide_dirpath" ] 
        then
            echo "Creating directory $hide_dirpath..."
            mkdir -p "$hide_dirpath"
        fi        
        hide_dir_exists=1
    fi
    
    if [ ! -f "$failed_file_path" ]
    then
        echo "File ..$fname does not exist. Skipping"
    else
        echo "Moving $fname to ../$hide_dirname/$fname"
    
        mv $failed_file_path $hide_fpath
    
        if [ $? != 0 ]
        then
            echo "Failed to move file!"
            exit 1
        fi
    fi
    
   
    
done < "$input"
