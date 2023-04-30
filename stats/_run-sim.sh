
LAUNCHD_PORT=9998 # Not used
OPP_RUNALL_JOBS=16
OPP_RUNALL_BATCH=4

if [ -z "$SIM_AUTO_MANAGE_SUMO" ]
then
    SIM_AUTO_MANAGE_SUMO=0
fi

if [ $SIM_AUTO_MANAGE_SUMO != 0 ]
then
    echo "Starting veins_launchd from $VEINS_LAUNCHD_PATH..."
    $VEINS_LAUNCHD_PATH -kd --port $SUMO_PORT
    if [ $? != 0 ]; then exit $?; fi
fi

input=$(realpath "opp-configs.txt")
while IFS= read -r opp_config
do
    echo "Config: $opp_config"
    echo "Evaluating from $EVAL_DIR/$opp_config.csv to $EVAL_DIR/$opp_config.pdf..."
        
    cd $SIMULATION_DIR

    opp_runall -b$OPP_RUNALL_BATCH -j$OPP_RUNALL_JOBS opp_run -m -u Cmdenv -c $opp_config -n .:../../src/drones_veins_project:../../../veins/examples/veins:../../../veins/src/veins --image-path=../../images:../../../veins/images -l ../../src/drones_veins_project -l ../../../veins/src/veins omnetpp.ini --repeat=10


    if [ $? != 0 ]
    then
        cd $WORKING_DIR
        exit 1
    fi
    
    cd $WORKING_DIR
        
    echo "Done for $opp_config"        
    echo ""
        
done < "$input"

if [ $SIM_AUTO_MANAGE_SUMO != 0 ]
then

    pid=$(cat /tmp/sumo-launchd.pid)
    echo "Killing sumo running with pid $pid..."

    kill -9 $pid
    
fi
