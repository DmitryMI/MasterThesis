mkdir -p $EVAL_DIR

FLAGS="-v"

if [ -z "$PATH_TO_RAW" ]
then
    echo "PATH_TO_RAW not defined!"
    exit 1
fi

if [ -z "$EVAL_DIR" ]
then
    echo "EVAL_DIR not defined!"
    exit 1
fi

#query=$(./get-scavetool-query.py)
query=$(./get-scavetool-query.sh)

input=$(realpath "opp-configs.txt")
while IFS= read -r opp_config
do
    echo "Config: $opp_config"
    echo "Exporting $PATH_TO_RAW from to $EVAL_DIR/$opp_config.csv..."
    scavetool export $FLAGS -o $EVAL_DIR/$opp_config.csv -f "$query" $PATH_TO_RAW/$opp_config-*.sca
    
    if [ $? != 0 ]
    then
        exit 1
    fi
    
    echo "Done for $opp_config"
    echo ""
    
done < "$input"


