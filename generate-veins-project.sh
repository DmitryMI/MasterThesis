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

# To remove duplicate example files
REMOVE_REDUNDANT_EXAMPLES=1

# To force project regeneration
FORCE_REGENERATION=0


ECHO_MSG="$PROJ_NAME\n$PROJ_BRIEF\n$PROJ_NAME_AS_FILE_NAME\n$PROJ_NAME_AS_MACRO_NAME"
ECHO_MSG="$ECHO_MSG\n$USE_INET\n$USE_INET3\n$USE_VEINS_VLC\n$USE_PLEXE\n$USE_SIMULTE"
ECHO_MSG="$ECHO_MSG\n$USE_SIMU5G\n"

while getopts ":hf" option; do
	case $option in
      		h) # display Help
		 	echo "-f to force project regeneration"
		 	echo "-h to show this help message"
		 	exit;;
     		f) # force regeneration
     			echo "Force regeneration enabled"
     			FORCE_REGENERATION=1     			
	esac
done

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


# Copying template files to the project
mkdir $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/simulation-environment

cp -R ./simulation-environment-template/* $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/simulation-environment

if [[ $? != 0 ]];
then
	exit
fi



# Calling Grid Gnerator to create a Manhattan Grid
cd ./grid-generator
source ./grid-generator.sh
cd ..

mv ./grid-generator/generated/* $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/simulation-environment

if [[ $? != 0 ]];
then
	exit
fi


if [[ $REMOVE_GIT_REPO == 1 ]];
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

if [[ $REMOVE_REDUNDANT_EXAMPLES == 1 ]];
then
	echo "Removing $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/examples..."
	rm -rf $PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/examples
	echo "Exaple files removed"
else
	echo "Removing example files skipped"
fi

printf "\n"


