MAKE_DIR=$(realpath ../drones_veins_project)
SIMULATION_DIR=$(realpath ../drones_veins_project/drones_veins_project/simulation/drones_veins_project)
OPP_CONFIG_NAME="Evaluation"
WORKING_DIR=$(pwd)
RESULTS_DIR=$WORKING_DIR/results
VEINS_LAUNCHD_PATH="$HOME/Software/veins/bin/veins_launchd"

DO_BUILD=0
DO_RUN=0
DO_COLLECT=0
DO_EVAL=0
DO_CLEAN=0

while getopts ":hbrcex-:" optchar; do
	case ${optchar} in	
		
        h) # display Help		 	
		 	echo "-b to build"
		 	echo "-r to run the simulation"
		 	echo "-c to collect results using scavatool"
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
     	x)
     	    echo "Clean enabled"
     	    DO_CLEAN=1
     	    ;;
     			
	esac
done

if [ $DO_BUILD == 0 ] && [ $DO_RUN == 0 ] && [ $DO_COLLECT == 0 ] && [ $DO_EVAL == 0 ] && [ $DO_CLEAN == 0 ]
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

if [[ $DO_COLLECT == 1 ]]
then
    echo "Collecting..."
    mkdir -p $RESULTS_DIR
    source _collect.sh
    echo ""
fi

if [[ $DO_EVAL == 1 ]]
then
    echo "Evaluating..."
    cd $RESULTS_DIR
    Rscript ../_eval-jammed-vehicles-num.R --opp_config $OPP_CONFIG_NAME
    echo ""
    Rscript ../_eval-received-announcements-num.R --opp_config $OPP_CONFIG_NAME
    
    echo ""
fi
