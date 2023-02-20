PROJ="TestCarJamming"

PATH_TO_RAW="../drones_veins_project/drones_veins_project/simulation/drones_veins_project/results"


scavetool export $PATH_TO_RAW/$PROJ-#0.sca -o $PROJ.csv -f "name(totalTimeInJam)"
