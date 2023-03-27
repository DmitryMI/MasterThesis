#!/bin/bash

if [ -z "$RUNSIM_SETVARS_GUARD" ]
then
    source "./setvars.sh"
    if [ $? != 0 ]
    then
        echo "Failed to read setvars.sh"
        exit 1
    fi
else
    echo "RUNSIM_SETVARS_GUARD already set to $RUNSIM_SETVARS_GUARD"
fi

source "../hpc/setvars.sh"

RUNFILE_GEN_SCRIPT="$INSTALLATION_DIR_RUNMAKER/veins_scripts/running/generateRunsFile.pl"
SIMULATION_DIR=$(realpath "../drones_veins_project/drones_veins_project/simulation/drones_veins_project")
PROJECT_EXECUTRABLE_REL="drones_veins_project/drones_veins_project/bin/drones_veins_project_run"
PROJECT_EXECUTABLE=$(realpath "../$PROJECT_EXECUTRABLE_REL")
echo $PROJECT_EXECUTABLE

RUNFILE="$(realpath ./runfile.txt)"
echo "Generating runfile..."
echo "" > $RUNFILE

if [ -z "$SINGULARITY_WORKSPACE_MNT" ]
then
    echo "SINGULARITY_WORKSPACE_MNT not defined!"
    exit 1
fi

LINE_TEMPLATE=". $SINGULARITY_WORKSPACE_MNT/MasterThesis/$PROJECT_EXECUTRABLE_REL -u Cmdenv -c %s -r %s"

input=$(realpath "opp-configs.txt")
wd_backup=$(pwd)
cd $SIMULATION_DIR
while IFS= read -r opp_config
do
    echo "Config: $opp_config"
    runnumbers=$($PROJECT_EXECUTABLE -c Evaluation -s -q runnumbers)
    # echo $runnumbers
    if [ $? != 0 ]
    then
        echo "Failed to request runnumbers!"
        exit
    fi
    
    for runnumber in $runnumbers
    do
        runline=$(printf "$LINE_TEMPLATE" $opp_config $runnumber)
        # echo "Runline: $runline"
        echo $runline >> $RUNFILE
    done  
       
done < "$input"

echo "Generated $RUNFILE:"
tail $RUNFILE -v -n 5

cd $wd_backup

