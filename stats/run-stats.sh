MAKE_DIR=$(realpath ../drones_veins_project)
SIMULATION_DIR=$(realpath ../drones_veins_project/drones_veins_project/simulation/drones_veins_project)
OPP_CONFIG_NAME="TestCarJammingWithoutJamAnnouncement"
WORKING_DIR=$(pwd)
RESULTS_DIR=$WORKING_DIR/results
VEINS_LAUNCHD_PATH="$HOME/Software/veins/bin/veins_launchd"

echo "Building..."
#source _build-sim.sh
echo ""

echo "Running..."
#source _run-sim.sh
echo ""

echo "Collecting..."
mkdir -p $RESULTS_DIR
source _collect.sh
echo ""

echo "Evaluating..."
cd $RESULTS_DIR
Rscript ../_eval-jammed-vehicles-num.R --opp_config $OPP_CONFIG_NAME
echo ""
