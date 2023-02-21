cd $SIMULATION_DIR

SUMO_PORT=9998

$VEINS_LAUNCHD_PATH -kd --port $SUMO_PORT

opp_run -m -u Cmdenv -c $OPP_CONFIG_NAME -n .:../../src/drones_veins_project:../../../veins/examples/veins:../../../veins/src/veins --image-path=../../images:../../../veins/images -l ../../src/drones_veins_project -l ../../../veins/src/veins omnetpp.ini --*.manager.port=$SUMO_PORT

cd $WORKING_DIR

pid=$(cat /tmp/sumo-launchd.pid)
echo "Killing sumo running with pid $pid..."

kill -9 $pid
