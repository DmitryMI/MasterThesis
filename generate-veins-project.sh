PROJ_NAME="Drones Veins Project"
PROJ_BRIEF="Improving urban traffic flow with drone-supported vehicular networks"
PROJ_NAME_AS_FILE_NAME="drones_veins_project"
PROJ_NAME_AS_MACRO_NAME="DRONES_VEINS_PROJECT"

# 1 - no, 2 - yes
USE_INET="1"
USE_INET3="1"
USE_VEINS_VLC="1"
USE_PLEXE="1"
USE_SIMULTE="1"
USE_SIMU5G="1"

# To copy SUMO templates. -s
COPY_SIMULATION_CONFIG_FILES=0

# To remove a git repository created by cookiecutter
REMOVE_GIT_REPO=1

# To remove duplicate example files
REMOVE_REDUNDANT_EXAMPLES=1

# To run cookiecutter. -p
RUN_COOKIECUTTER=0

# To force project regeneration. -f
FORCE_REGENERATION=0

# To generate and copy road network. -m
GENERATE_ROAD_NET=0
GENERATE_ROAD_NET_GRID_SIZE=7
GENERATE_ROAD_NET_STREET_LENGTH=100


ECHO_MSG="$PROJ_NAME\n$PROJ_BRIEF\n$PROJ_NAME_AS_FILE_NAME\n$PROJ_NAME_AS_MACRO_NAME"
ECHO_MSG="$ECHO_MSG\n$USE_INET\n$USE_INET3\n$USE_VEINS_VLC\n$USE_PLEXE\n$USE_SIMULTE"
ECHO_MSG="$ECHO_MSG\n$USE_SIMU5G\n"

while getopts ":hpfsm-:" optchar; do
	case ${optchar} in
		-)
			case "${OPTARG}" in
				grid_size)
					val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
				    	GENERATE_ROAD_NET_GRID_SIZE=${val}
					echo "Manhatten Grid size set to $GENERATE_ROAD_NET_GRID_SIZE"
				    	;;
				street_length)
					val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
				    	GENERATE_ROAD_NET_STREET_LENGTH=${val}
				    	echo "Manhatten Grid street length set to $GENERATE_ROAD_NET_STREET_LENGTH"
				    	;;
			esac;;
		
      		h) # display Help		 	
		 	echo "-h to show this help message"
		 	echo "-p to run cookiecutter"
		 	echo "-f to force project regeneration"
		 	echo "-s to copy SUMO template files"
		 	echo "-m to genetate road network"
		 	echo "--grid_size to set the grid size"
		 	echo "--street_length to set streets length"
		 	exit;;
		 	
		p)
     			echo "Cookiecutter invocation enabled"
     			RUN_COOKIECUTTER=1     	
     			;;
     		f)
     			echo "Force regeneration enabled"
     			FORCE_REGENERATION=1   
     			;;  	
     		s)
     			echo "SUMO config copying enabled"
     			COPY_SIMULATION_CONFIG_FILES=1	
     			;;
     		m)
     			echo "Road network generation enabled"
     			GENERATE_ROAD_NET=1	
     			;;
     			
	esac
done

if [[ $RUN_COOKIECUTTER != 0 ]]; then

	if [[ $FORCE_REGENERATION == 1 ]];
	then
		echo "Removing project files..."
		rm -rf $PROJ_NAME_AS_FILE_NAME
		echo "Project files removed"
	fi

	printf "$ECHO_MSG" | cookiecutter ./veins-project-generator

	cookiecutter_code=$?

	if [[ $cookiecutter_code != 0 ]]
	then
		exit
	fi

	printf "\n"
	
	if [[ $REMOVE_GIT_REPO != 0 ]];
	then

		echo "Removing internal git repository..."
		
		cd $PROJ_NAME_AS_FILE_NAME
		rm -rf .git
		cd ..
		
		echo "Internal git repository removed"
	else
		echo "Removing internal git repository skipped"
	fi

	printf "\n"

	if [[ $REMOVE_REDUNDANT_EXAMPLES != 0 ]];
	then
		echo "Removing $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/examples..."
		rm -rf $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/examples
		echo "Exaple files removed"
		
		echo "Patching .nedfolders to remove examples directory..."
		# examples/drones_veins_project
		# POTENTIALLY DANGEROUS! Relies on line order
		sed -i '2d' $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/.nedfolders
		echo "Examples removed from .nedfolders"
	else
		echo "Removing example files skipped"
	fi
else
	echo "Cookiecutter skipped"	
fi

printf "\n"


simulation_env_path=./$PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/simulation/$PROJ_NAME_AS_FILE_NAME/

if [[ $COPY_SIMULATION_CONFIG_FILES != 0 ]];
then

	# Copying template files to the project
	
	mkdir -p $simulation_env_path

	cp ./simulation-environment-template/* $simulation_env_path

	if [[ $? != 0 ]];
	then
		exit
	fi

	echo "Adding simulation config directoy to .nedfolders..."
	echo "simulation/drones_veins_project" >> $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/.nedfolders
	echo "Simulation config added to .nedfoldes"
	
else
	echo "Simulation files copying skipped"
fi

printf "\n"


if [[ $GENERATE_ROAD_NET != 0 ]]; then
	echo "Calling Grid Gnerator to create a Manhattan Grid"
	
	cd ./grid-generator
	./grid-generator.sh --grid_size $GENERATE_ROAD_NET_GRID_SIZE --street_length $GENERATE_ROAD_NET_STREET_LENGTH
	cd ..

	echo "Moving Manhatten Grid files to veins project..."
	
	mv ./grid-generator/generated/* $simulation_env_path

	if [[ $? != 0 ]];
	then
		exit
	fi

else
	echo "Road network generation skipped"
fi


printf "\n"


