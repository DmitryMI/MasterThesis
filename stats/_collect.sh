mkdir -p $EVAL_DIR

FLAGS="-v"

query=$(./get-scavetool-query.py)

input=$(realpath "opp-configs.txt")
while IFS= read -r opp_config
do
    echo "Config: $opp_config"
    echo "Exporting to $EVAL_DIR/$opp_config.csv..."
    scavetool export $FLAGS -o $EVAL_DIR/$opp_config.csv -f "$query" $PATH_TO_RAW/$opp_config-*.sca
    echo "Done for $opp_config"
    echo ""
    
done < "$input"


