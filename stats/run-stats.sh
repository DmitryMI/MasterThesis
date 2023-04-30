#!/bin/bash

if [[ $RUNSIM_SETVARS_GUARD != 1 ]]
then
    source ./setvars.sh
fi

MAKE_DIR=$(realpath ../drones_veins_project)
SIMULATION_DIR=$(realpath ../drones_veins_project/drones_veins_project/simulation/drones_veins_project)
WORKING_DIR=$(pwd)

DO_BUILD=0
DO_RUN=0
DO_COLLECT=0
DO_EVAL=0
DO_CLEAN=0
DO_VALIDATE=0

while getopts ":hbrcevx-:" optchar; do
	case ${optchar} in	
		
        h) # display Help		 	
		 	echo "-b to build"
		 	echo "-r to run the simulation"
		 	echo "-c to collect results using scavatool"
		 	echo "-v to validate results using ScaveValidator"
		 	echo "-e to plot results"
		 	echo "No flag is equal to -brce"
		 	exit;;
		 	
		b)
     		echo "Building enabled"
     		DO_BUILD=1     	
     		;;
     	r)
     	    echo "Running enabled"
     		DO_RUN=1   
     		;;  	
     	c)
     		echo "Collecting enabled"
     		DO_COLLECT=1	
     		;;
     	e)
     		echo "Evaluation enabled"
     		DO_EVAL=1	
     		;;
        v)
     		echo "Validation enabled"
     		DO_VALIDATE=1	
     		;;
     	x)
     	    echo "Clean enabled"
     	    DO_CLEAN=1
     	    ;;
     			
	esac
done

if [ $DO_BUILD == 0 ] && [ $DO_RUN == 0 ] && [ $DO_COLLECT == 0 ] && [ $DO_EVAL == 0 ] && [ $DO_CLEAN == 0 ] && [ $DO_VALIDATE == 0 ]
then
    echo "No action specified, doing the whole pipeline."
    DO_BUILD=1   
    DO_RUN=1  
    DO_COLLECT=1
    DO_EVAL=1
fi

echo ""

if [[ $DO_CLEAN == 1 ]]
then
    echo "Cleaning..."
    rm -rf $SIMULATION_DIR/results
    echo ""
fi

if [[ $DO_BUILD == 1 ]]
then
    echo "Building..."
    source _build-sim.sh
    echo ""
fi

if [[ $DO_RUN == 1 ]]
    then
    echo "Running..."
    source _run-sim.sh
    echo ""
fi

if [[ $DO_VALIDATE == 1 ]]
then
    echo "Validating..."
    
    if [ -z "$EVAL_DIR" ]
    then
        echo "run-stats.sh validate: EVAL_DIR not set!"
        exit 1
    fi
    
    mkdir -p "$EVAL_DIR"
    
    if [ -z "$PATH_TO_RAW" ]
    then
        PATH_TO_RAW="$SIMULATION_DIR/results"
        echo "PATH_TO_RAW not set! Setting to default $PATH_TO_RAW"
    else
        echo "PATH_TO_RAW = $PATH_TO_RAW"        
    fi
    
    ./scave-validator-vs/ScaveValidator/ScaveValidator.py ./scave-validator-vs/scave-schema.txt "$PATH_TO_RAW" -v 1 -o ScaveValidator-Report.txt
    
    if [ $? != 0 ]
    then
        exit $?
    fi
    
    echo ""
fi

if [[ $DO_COLLECT == 1 ]]
then
    echo "Collecting..."
    
    if [ -z "$EVAL_DIR" ]
    then
        echo "run-stats.sh collect: EVAL_DIR not set!"
        exit 1
    fi
    
    mkdir -p "$EVAL_DIR"
    
    if [ -z "$PATH_TO_RAW" ]
    then
        PATH_TO_RAW="$SIMULATION_DIR/results"
        echo "PATH_TO_RAW not set! Setting to default $PATH_TO_RAW"
    else
        echo "PATH_TO_RAW = $PATH_TO_RAW"        
    fi
    
    source _collect.sh
    echo ""
fi

if [[ $DO_EVAL == 1 ]]
then
    echo "Evaluating..."
    
    
    if [ -z "$CSV_DIR" ]
    then
        CSV_DIR=$EVAL_DIR
    fi
    
    echo "CSV_DIR: $CSV_DIR"
    
    input=$(realpath "opp-configs.txt")
    while IFS= read -r opp_config
    do
        echo "Config: $opp_config"
        echo "Evaluating from $CSV_DIR/$opp_config.csv to $EVAL_DIR/$opp_config.pdf..."
        
        cd ./r-eval-scripts
        Rscript ./main.R -i $CSV_DIR/$opp_config.csv -o $EVAL_DIR

        if [ $? != 0 ]
        then
            cd ..
            exit 1
        fi
        
        cd ..
        
        echo "Done for $opp_config"
        echo ""
        
    done < "$input"
    
    
    echo ""
fi
