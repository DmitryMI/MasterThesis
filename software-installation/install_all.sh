#!/bin/bash

if test -z "$1" 
then
      echo "Env file not specified"
else
      echo "Sourcing $1"
      source $1
fi

if [[ $SETVARS_GUARD != 1 ]]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit -1
fi

function run_installation_script () {
	echo "Running $1..."
	source $1
	sleep $SLEEP_SEC 
	
	if [[ $? != 0 ]];
	then
		exit -1
	fi
	
	printf "\n\n"
}

pwd

if test -f "$INSTALLATION_DIR"; then
	printf "Installation directory already exists."
else
	mkdir $INSTALLATION_DIR
fi

run_installation_script "./_install_prereq.sh"

run_installation_script "./_install_omnetpp.sh"

run_installation_script "./_install_sumo.sh"

run_installation_script "./_install_veins.sh"

if [[ $RUNTIME_ONLY == 0 ]]
then
    run_installation_script "./_install_python311.sh"
    run_installation_script "./_install_r.sh"
    run_installation_script "./_install_cookiecutter.sh"
    run_installation_script "./_install_singularity.sh"
fi

printf "All done! Reboot required for changes in .profile to be applied.\n\n"
