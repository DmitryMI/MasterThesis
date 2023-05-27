#!/bin/bash

SUMO_TOOLS_PATH="/home/$(whoami)/Software/sumo-1.8.0/tools"
PROJ_DIR="./generated/"
OMNETPP_INI_PATH=""
DO_VISUALIZE=0

if [ -z "$GRID_GENERATOR_VARS_GUARD" ]
then
    PROJ_NAME="drones"
    GRID_SIZE=7
    STREET_LENGTH=100
    GRID_SUBD=1
    SUMO_TOOLS_PATH="/home/$(whoami)/Software/sumo-1.8.0/tools"

    # Number of trips (vehicles) will be (TRIPS_END_TIME - TRIPS_START_TIME) / TRIPS_PERIOD
    TRIPS_START_TIME=0
    TRIPS_END_TIME=60
    TRIPS_PERIOD=1

    # Number of intermediate points in a trip
    TRIPS_INTERMEDIATES=64
fi

mkdir -p $PROJ_DIR

pwd

dir_backup=$(pwd)
cd $PROJ_DIR

# Generating a grid-network of roads
netgenerate --grid --grid.number $GRID_SIZE --grid.length $STREET_LENGTH --default.lanenumber 1 --output-file $PROJ_NAME.net.xml

# Generating buildings
# ../grid-generator-vs/grid_generator_vs.py $PROJ_NAME --grid.x-number $GRID_SIZE --grid.y-number $GRID_SIZE --grid.length $STREET_LENGTH --block_size $GRID_SUBD --ini_path $OMNETPP_INI_PATH
../grid-generator-vs/grid_generator_vs.py $PROJ_NAME --grid.x-number $GRID_SIZE --grid.y-number $GRID_SIZE --grid.length $STREET_LENGTH --block_size $GRID_SUBD

if [ -z "$TRIPS_MIN_DISTANCE" ]
then
    echo "TRIPS_MIN_DISTANCE not defined. Stripping CLI arguments"
    TRIPS_MIN_DISTANCE_ARG=""
else
    TRIPS_MIN_DISTANCE_ARG="--min-distance $TRIPS_MIN_DISTANCE"
fi

# Generating random trips
TRIPS_MIN_DISTANCE=$(expr $GRID_SIZE \* $STREET_LENGTH)
# echo "RandomTrips will use min distance of $TRIPS_MIN_DISTANCE"
python3 $SUMO_TOOLS_PATH/randomTrips.py -n $PROJ_NAME.net.xml -b $TRIPS_START_TIME -e $TRIPS_END_TIME -p $TRIPS_PERIOD --random -i $TRIPS_INTERMEDIATES -o $PROJ_NAME.trips.xml $TRIPS_MIN_DISTANCE_ARG

# Applying duarouter-randomTrips bugfix
str_to_replace=' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://sumo.dlr.de/xsd/routes_file.xsd"'
sed -i -e "s/<routes.*>/<routes>/g" $PROJ_NAME.trips.xml

# Generating actual vehicle routes based on trips
duarouter -n $PROJ_NAME.net.xml --route-files $PROJ_NAME.trips.xml -o $PROJ_NAME.rou.xml --remove-loops

if [ $? != 0 ]
then
    echo "Duarouter failed!"
    exit $?
fi

echo "Extracting routes..."
../grid-generator-vs/route_extractor.py $PROJ_NAME.rou.xml

if [ $? != 0 ]
then
    echo "Route extractor failed!"
    exit $?
fi

rm $PROJ_NAME.rou.xml
mv $PROJ_NAME.rou.extracted.xml $PROJ_NAME.rou.xml

if [ $DO_VISUALIZE == 1 ]
then
    # Visualize the road network and buildings
    netedit -s $PROJ_NAME.net.xml -a $PROJ_NAME.poly.xml
fi
