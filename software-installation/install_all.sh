#!/bin/bash

if [ -z "$SETVARS_GUARD" ]
then
    source ../setvars.sh
fi

mkdir -p $INSTALLATION_DIR_SUMO
mkdir -p $INSTALLATION_DIR_OMNETPP

. ./_install_prereq.sh

. ./_install_omnetpp.sh

if [ $? != 0 ]; then exit 1; fi

. ./_install_sumo.sh

. ./_install_veins.sh

. ./_install_hpc_utils.sh

if [ $RUNTIME_ONLY == 0 ]
then
    . ./_install_python311.sh
    . ./_install_r.sh
    . ./_install_cookiecutter.sh
    . ./_install_singularity.sh
fi

printf "All done! Reboot required for changes in .profile to be applied.\n\n"
