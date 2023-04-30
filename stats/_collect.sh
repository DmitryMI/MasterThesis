#!/bin/bash

mkdir -p $EVAL_DIR

# SCAVETOOL_FLAGS="-v"
SCAVETOOL_FLAGS=""
SCAVE_FLAGS="-v 1 --no_progress_bar true"

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
    echo "Exporting from $PATH_TO_RAW to $EVAL_DIR/$opp_config.csv..."
    scavetool export $SCAVETOOL_FLAGS -o $EVAL_DIR/$opp_config.csv -f "$query" $PATH_TO_RAW/$opp_config-*.sca

    # regex="$opp_config-.*"
    # python3 ./scave-vs/Scave/Scave.py "$PATH_TO_RAW" "$EVAL_DIR/$opp_config.csv" -r "$regex" -s "./scave-validator-vs/scave-schema.txt" --filters_file "scavetool-variables.txt" $SCAVE_FLAGS
    
    if [ $? != 0 ]
    then
        exit 1
    fi
    
    echo "Done for $opp_config"
    echo ""
    
done < "$input"


