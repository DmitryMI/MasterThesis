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

# To remove a git repository created by cookiecutter
REMOVE_GIT_REPO=1


ECHO_MSG="$PROJ_NAME\n$PROJ_BRIEF\n$PROJ_NAME_AS_FILE_NAME\n$PROJ_NAME_AS_MACRO_NAME"
ECHO_MSG="$ECHO_MSG\n$USE_INET\n$USE_INET3\n$USE_VEINS_VLC\n$USE_PLEXE\n$USE_SIMULTE"
ECHO_MSG="$ECHO_MSG\n$USE_SIMU5G\n"

printf "$ECHO_MSG"

printf "$ECHO_MSG" | cookiecutter ./veins-project-generator

cookiecutter_code=$?

printf "\n"

if [[ $REMOVE_GIT_REPO == 1 ]] && [[ $cookiecutter_code == 0 ]];
then

	echo "Removing internal git repository..."
	
	cd $PROJ_NAME_AS_FILE_NAME
	rm -rf .git
	cd ..
	
	echo "Internal git repository removed"
else
	echo "Removing internal git repository skipped"
fi
