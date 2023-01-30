printf "Installing Python3.11...\n\n"

sudo apt install -y software-properties-common -y

sudo add-apt-repository --yes ppa:deadsnakes/ppa

sudo apt -y install python3.11

python_version=$(python3.11 --version)

if [[ "$python_version" == *"3.11"* ]];
then
	echo "$python_version installed successfully"
else
	echo "Failed to install Python 3.11"
	exit -1
fi

sudo apt -y install python3-pip

pip_version=$(pip3 --version)

if [[ "$pip_version" == *"pip"* ]];
then
	echo "$pip_version installed successfully"
else
	echo "Failed to install Pip 3"
	exit -1
fi


