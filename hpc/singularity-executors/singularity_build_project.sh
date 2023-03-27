#!/bin/bash

#SCRIPTPATH=$(dirname "$SCRIPT")
#cd $SCRIPTPATH
#pwd

cd ~/scripts/hpc/singularity-executors
echo "Running singularity_build_project.sh from $(pwd)."

if [ -z "$HPC_SETVARS_GUARD" ]
then
    source "../setvars.sh"
fi

echo "SCRATCH_WORKSPACE = $SCRATCH_WORKSPACE"
echo "SINGULARITY_WORKSPACE_MNT = $SINGULARITY_WORKSPACE_MNT"

REPO_MNT="$SINGULARITY_WORKSPACE_MNT/MasterThesis"
echo "REPO_MNT = $REPO_MNT"

check_omnetpp=$(which omnetpp)
echo "Checking OMNet++: $check_omnetpp"

if [ -z "$check_omnetpp" ]
then
    echo "OMNeT++ not installed!"
    exit 1
fi

check_sumo=$(which sumo)
echo "Checking SUMO: $check_sumo"
if [ -z "$check_sumo" ]
then
    echo "SUMO not installed!"
    exit 1
fi

if [ -d "$SINGULARITY_WORKSPACE_MNT" ];
then
echo "$SINGULARITY_WORKSPACE_MNT directory found, proceeding."
else
	echo "Run the container with --bind $BEEGFS_WORKSPACE:$SINGULARITY_WORKSPACE_MNT:rw to bind a directory."
	exit 1
fi 

cd $REPO_MNT
git pull
if [ $? != 0 ]; then exit $?; fi

# Building 
cd $REPO_MNT/drones_veins_project
if [ $? != 0 ]; then exit $?; fi

echo "Calling setenv..."
. ./setenv
if [ $? != 0 ]; then exit $?; fi
echo "Calling configure..."
. ./configure
if [ $? != 0 ]; then exit $?; fi

echo "Making..."
mkdir -p veins/bin
mkdir -p drones_veins_project/bin
make -j8
if [ $? != 0 ]; then exit $?; fi
