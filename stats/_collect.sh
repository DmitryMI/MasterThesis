
cd $WORKING_DIR

pwd

scavetool export -o $EVAL_DIR/$OPP_CONFIG_NAME.csv -f "name(totalTimeInJam) OR name(receivedJammingAnnouncementsNum)" $PATH_TO_RAW/$OPP_CONFIG_NAME-*.sca

