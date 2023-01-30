#!/bin/bash

INSTALLATION_DIR="/home/$(whoami)/Software"
DOWNLOADS_DIR="/home/$(whoami)/Downloads"
SLEEP_SEC=2

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

run_installation_script "./_install_python311.sh"

run_installation_script "./_install_cookiecutter.sh"

run_installation_script "./_install_omnetpp.sh"

run_installation_script "./_install_sumo.sh"

run_installation_script "./_install_veins.sh"

run_installation_script "./_install_r.sh"


printf "All done! Reboot required for changes in .profile to be applied.\n\n"
