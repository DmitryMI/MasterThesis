mkdir -p $EVAL_DIR

input=$(realpath "opp-configs.txt")
while IFS= read -r opp_config
do
    echo "Config: $opp_config"
    echo "Exporting to $EVAL_DIR/$opp_config.csv..."
    scavetool export -o $EVAL_DIR/$opp_config.csv -f "name(totalTimeInJam) OR name(receivedJammingAnnouncementsNum)" $PATH_TO_RAW/$opp_config-*.sca
    echo "Done for $opp_config"
    echo ""
    
done < "$input"


