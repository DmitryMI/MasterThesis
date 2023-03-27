#!/bin/bash

# https://github.com/veins/runmaker

if [ "$SETVARS_GUARD" != 1 ]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit 1
fi

wd_backup=$(pwd)
cd $INSTALLATION_DIR_RUNMAKER

git clone https://github.com/veins/runmaker
git clone https://github.com/veins/veins_scripts

cd $wd_backup
