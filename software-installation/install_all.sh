#!/bin/bash

if test -z "$1" 
then
    echo "Env file not specified"
else
    echo "Sourcing $1"
    source $1
fi

if [ $SETVARS_GUARD != 1 ]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit -1
fi

mkdir -p $INSTALLATION_DIR_SUMO
mkdir -p $INSTALLATION_DIR_OMNETPP

. ./_install_prereq.sh

. ./_install_omnetpp.sh

. ./_install_sumo.sh

. ./_install_veins.sh

if [ $RUNTIME_ONLY == 0 ]
then
    . ./_install_python311.sh
    . ./_install_r.sh
    . ./_install_cookiecutter.sh
    . ./_install_singularity.sh
fi

printf "All done! Reboot required for changes in .profile to be applied.\n\n"
