PATH_TO_RAW="$SIMULATION_DIR/results"

cd $WORKING_DIR

pwd

scavetool export -o $RESULTS_DIR/results.csv -f "name(totalTimeInJam)" $PATH_TO_RAW/$OPP_CONFIG_NAME-*.sca
