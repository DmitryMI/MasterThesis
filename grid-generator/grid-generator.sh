PROJ_NAME="drones"
GRID_SIZE=7
SUMO_TOOLS_PATH="/home/dmitriy/software/sumo-1.8.0/tools"
PROJ_DIR="./generated/"

# Number of trips (vehicles) will be (TRIPS_END_TIME - TRIPS_START_TIME) / TRIPS_PERIOD
TRIPS_START_TIME=0
TRIPS_END_TIME=60
TRIPS_PERIOD=1		# Must be positive!

# Number of intermediate points in a trip
TRIPS_INTERMEDIATES=64

mkdir $PROJ_DIR

dir_backup=$(pwd)
cd $PROJ_DIR

# Generating a grid-network of roads
netgenerate --grid --grid.number $GRID_SIZE --output-file $PROJ_NAME.net.xml

# Generating buildings
../grid-generator-vs/grid_generator_vs.py $PROJ_NAME $GRID_SIZE $GRID_SIZE

# Generating random trips
python3 $SUMO_TOOLS_PATH/randomTrips.py -n $PROJ_NAME.net.xml -b $TRIPS_START_TIME -e $TRIPS_END_TIME -p $TRIPS_PERIOD --random -i $TRIPS_INTERMEDIATES -o $PROJ_NAME.trips.xml

# Generating actual vehicle routes based on trips
duarouter -n $PROJ_NAME.net.xml --route-files $PROJ_NAME.trips.xml -o $PROJ_NAME.rou.xml

# Visualize the road network and buildings
# netedit -s $PROJ_NAME.net.xml -a $PROJ_NAME.poly.xml

cd $dir_backup
