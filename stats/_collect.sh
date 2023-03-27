PATH_TO_RAW="$SIMULATION_DIR/results"

cd $WORKING_DIR

pwd

scavetool export -o $RESULTS_DIR/$OPP_CONFIG_NAME.csv -f "name(totalTimeInJam) OR name(receivedJammingAnnouncementsNum)" $PATH_TO_RAW/$OPP_CONFIG_NAME-*.sca

