cd $SIMULATION_DIR

SUMO_PORT=9998
OPP_RUNALL_JOBS=1
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

pwd
opp_runall -b$OPP_RUNALL_BATCH -j$OPP_RUNALL_JOBS opp_run -m -u Cmdenv -c $OPP_CONFIG_NAME -n .:../../src/drones_veins_project:../../../veins/examples/veins:../../../veins/src/veins --image-path=../../images:../../../veins/images -l ../../src/drones_veins_project -l ../../../veins/src/veins omnetpp.ini --*.manager.port=$SUMO_PORT

cd $WORKING_DIR

if [ $SIM_AUTO_MANAGE_SUMO != 0 ]
then

    pid=$(cat /tmp/sumo-launchd.pid)
    echo "Killing sumo running with pid $pid..."

    kill -9 $pid
    
fi
