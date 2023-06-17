#!/bin/bash

CPUS_PER_TASK=24
NTASKS_MAX=20

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

echo "Building project..."
WORKING_DIR=$(pwd)
source ./_build-sim.sh
if [ $? != 0 ]
then
    echo "Building failed!"
    exit $?
fi

echo "Building finished!"

RUNFILE_GEN_SCRIPT="$INSTALLATION_DIR_RUNMAKER/veins_scripts/running/generateRunsFile.pl"
SIMULATION_DIR=$(realpath "../drones_veins_project/drones_veins_project/simulation/drones_veins_project")
#PROJECT_INI_REL="drones_veins_project/drones_veins_project/simulation/drones_veins_project/omnetpp.ini"
#PROJECT_INI=$(realpath "../$PROJECT_INI_REL")
PROJECT_EXECUTRABLE_REL="drones_veins_project/drones_veins_project/bin/drones_veins_project_run"
PROJECT_EXECUTABLE=$(realpath "../$PROJECT_EXECUTRABLE_REL")
RUNFILE="$(realpath ./runfile.txt)"
RUNCOUNTER=0

echo "Generating runfile..."
echo "" > $RUNFILE

if [ -z "$SINGULARITY_WORKSPACE_MNT" ]
then
    echo "SINGULARITY_WORKSPACE_MNT not defined!"
    exit 1
fi

LINE_TEMPLATE=". $SINGULARITY_WORKSPACE_MNT/MasterThesis/$PROJECT_EXECUTRABLE_REL --result-dir=$SINGULARITY_BEEGFS_MNT/omnetpp-results -u Cmdenv -c %s -r %s"

input=$(realpath "opp-configs.txt")
cd $SIMULATION_DIR
while IFS= read -r opp_config
do
    if [[ $opp_config =~ ^#.* ]]
    then
	    echo "Line $opp_config ignored"
    else
    
        echo "Config: $opp_config"
        runnumbers=$($PROJECT_EXECUTABLE -c $opp_config -s -q runnumbers)
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
            RUNCOUNTER=$((RUNCOUNTER + 1))
        done  
    fi
       
done < "$input"

echo "Total $RUNCOUNTER runs."

if [ $RUNCOUNTER == 0 ]
then
    echo "No runs generated! Nothing to schedule."
    exit
fi

echo "Generated $RUNFILE:"
tail $RUNFILE -v -n 5

cd $WORKING_DIR

cd ../hpc/

echo "Scheduling Build job..."
JOBFILE_TO_SCHEDULE="build.jobfile"
source ./schedule_jobfile.sh

if [ -z $SLURM_JOB_ID ]
then
    echo "SLURM_JOB_ID not set!"
    exit 1
fi



echo "Uploading runfile.txt to BeeGFS..."

./upload_file.sh ../stats/runfile.txt "$BEEGFS_WORKSPACE"
if [ $? != 0 ]
then
    echo "Failed to upload runfile!"
    exit 1
fi

echo "Clearing remote raw data..."
./clear_results.sh



echo "Generating run.jobfile..."
echo "#!/bin/bash" > ./run.jobfile.vars
echo "# AUTOGENERATED FILE! DO NOT EDIT!" >> ./run.jobfile.vars
echo "DEPENDENCY=$SLURM_JOB_ID" >> ./run.jobfile.vars

NTASKS=0

(( NTASKS = (RUNCOUNTER + CPUS_PER_TASK - 1) / CPUS_PER_TASK ))

if [ $NTASKS -gt "$NTASKS_MAX" ]
then
    NTASKS=$NTASKS_MAX
    echo "NTATSKS limited to $NTASKS"  
fi

echo "NTASKS=$NTASKS" >> ./run.jobfile.vars
echo "CPUS_PER_TASK=$CPUS_PER_TASK" >> ./run.jobfile.vars
echo "RUNCOUNTER=$RUNCOUNTER" >> ./run.jobfile.vars

./generate_run_jobfile.sh



echo "Scheduling run job..."
JOBFILE_TO_SCHEDULE="run.jobfile"
source ./schedule_jobfile.sh
echo "Run Job scheduled!"



echo "Generating eval.jobfile..."
echo "#!/bin/bash" > ./eval.jobfile.vars
echo "# AUTOGENERATED FILE! DO NOT EDIT!" >> ./eval.jobfile.vars
echo "DEPENDENCY=$SLURM_JOB_ID" >> ./eval.jobfile.vars

./generate_eval_jobfile.sh



echo "Scheduling eval job..."
JOBFILE_TO_SCHEDULE="eval.jobfile"
source ./schedule_jobfile.sh
echo "Eval Job scheduled!"

./read_runfile.sh
cd $WORKING_DIR

# cd ../hpc
# ./get-run-info.py -w 30 -m 10


