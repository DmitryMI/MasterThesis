INSTALLATION_DIR="/home/$(whoami)/Software"
DOWNLOADS_DIR="/home/$(whoami)/Downloads"
SLEEP_SEC=2

pwd

mkdir $INSTALLATION_DIR

printf "Installing prerequisites...\n\n"
sleep $SLEEP_SEC

source ./_install_prereq.sh

if [[ $? != 0 ]];
then
	exit -1
fi

printf "\n\n"


printf "Installing Python 3.11...\n\n"
sleep $SLEEP_SEC
source ./_install_python311.sh

if [[ $? != 0 ]];
then
	exit -1
fi

printf "\n\n"


printf "Installing OMNeT++...\n\n"
sleep $SLEEP_SEC
source ./_install_omnetpp.sh

if [[ $? != 0 ]];
then
	exit -1
fi
