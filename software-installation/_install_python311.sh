printf "Installing Python3.11...\n\n"

SUDO_PREFIX=""
if [ "$EUID" -ne 0 ]
then 
    SUDO_PREFIX="sudo"
fi


$SUDO_PREFIX apt install -y software-properties-common -y

$SUDO_PREFIX add-apt-repository --yes ppa:deadsnakes/ppa

$SUDO_PREFIX apt -y install python3.11

python_version=$(python3.11 --version)

if [[ "$python_version" == *"3.11"* ]];
then
	echo "$python_version installed successfully"
else
	echo "Failed to install Python 3.11"
	exit -1
fi

$SUDO_PREFIX apt -y install python3-pip

pip_version=$(pip3 --version)

if [[ "$pip_version" == *"pip"* ]];
then
	echo "$pip_version installed successfully"
else
	echo "Failed to install Pip 3"
	exit -1
fi


