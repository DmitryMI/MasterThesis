
source setvars.sh

echo "Calling Grid Gnerator to create a Simple Manhattan Grid"

wd=$(pwd)
	
cd ./grid-generator
source grid-vars-simple.sh
source grid-generator-simple.sh
cd $wd

echo "Moving Simple Manhatten Grid files to veins project..."
	
simulation_env_path=./$PROJ_NAME_AS_FILE_NAME/$PROJ_NAME_AS_FILE_NAME/simulation/$PROJ_NAME_AS_FILE_NAME/
cp ./grid-generator/generated/* $simulation_env_path

