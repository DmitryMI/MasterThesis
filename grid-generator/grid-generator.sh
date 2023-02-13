PROJ_NAME="drones-simple"
GRID_SIZE=7
STREET_LENGTH=100
SUMO_TOOLS_PATH="/home/$(whoami)/Software/sumo-1.8.0/tools"
OMNETPP_INI_PATH=""
PROJ_DIR="./generated/"

# Number of trips (vehicles) will be (TRIPS_END_TIME - TRIPS_START_TIME) / TRIPS_PERIOD
TRIPS_START_TIME=0
TRIPS_END_TIME=60
TRIPS_PERIOD=30		# Must be positive!

# Number of intermediate points in a trip
TRIPS_INTERMEDIATES=64

while getopts ":h-:" optchar; do
	case ${optchar} in
		-)
			case "${OPTARG}" in
				grid_size)
					val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
				    	GRID_SIZE=${val}
					echo "Grid Generator: Manhatten Grid size set to $GRID_SIZE"
				    	;;
				street_length)
					val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
				    	STREET_LENGTH=${val}
				    	echo "Grid Generator: Manhatten Grid street length set to $STREET_LENGTH"
				    	;;
				omnetpp_ini)
				    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
				    	OMNETPP_INI_PATH=${val}
				    	echo "Grid Generator: omnetpp.ini path set to $OMNETPP_INI_PATH"
				    	;;
			esac;;
		h)
			echo "--grid_size to set number of joints in the Grid"
			echo "--street_length to set length of a street in meters"
			exit;;

	esac
done

mkdir $PROJ_DIR

pwd

dir_backup=$(pwd)
cd $PROJ_DIR

# Generating a grid-network of roads
netgenerate --grid --grid.number $GRID_SIZE --grid.length $STREET_LENGTH --output-file $PROJ_NAME.net.xml

# Generating buildings
../grid-generator-vs/grid_generator_vs.py $PROJ_NAME --grid.x-number $GRID_SIZE --grid.y-number $GRID_SIZE --grid.length $STREET_LENGTH --ini_path $OMNETPP_INI_PATH

# Generating random trips
python3 $SUMO_TOOLS_PATH/randomTrips.py -n $PROJ_NAME.net.xml -b $TRIPS_START_TIME -e $TRIPS_END_TIME -p $TRIPS_PERIOD --random -i $TRIPS_INTERMEDIATES -o $PROJ_NAME.trips.xml

# Applying duarouter-randomTrips bugfix
str_to_replace=' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://sumo.dlr.de/xsd/routes_file.xsd"'
sed -i -e "s/<routes.*>/<routes>/g" $PROJ_NAME.trips.xml

# Generating actual vehicle routes based on trips
duarouter -n $PROJ_NAME.net.xml --route-files $PROJ_NAME.trips.xml -o $PROJ_NAME.rou.xml

# Visualize the road network and buildings
netedit -s $PROJ_NAME.net.xml -a $PROJ_NAME.poly.xml

cd $dir_backup
