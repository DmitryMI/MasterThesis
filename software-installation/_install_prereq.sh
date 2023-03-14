printf "Installing prerequisites...\n\n"

if [[ $SETVARS_GUARD != 1 ]]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit -1
fi

SUDO_PREFIX=""

if [ "$EUID" -ne 0 ]
then 
    SUDO_PREFIX="sudo"
fi

$SUDO_PREFIX apt -y update

$SUDO_PREFIX apt -y install wget

if [[ $RUNTIME_ONLY == 0 ]]
then
    $SUDO_PREFIX apt -y install git-core gitk git-gui tig clang bison flex tcl-dev tk-dev openjdk-17-jre qtbase5-dev libopenscenegraph-dev xvfb libwebkit2gtk-4.0-dev doxygen graphviz python3-numpy python3-pandas python3-matplotlib libxerces-c-dev libproj-dev libgdal-dev libfox-1.6-dev libavformat-dev libavcodec-dev libswscale-dev python-dev cmake xterm clang-format uncrustify valgrind gdb lldb nemiver
else
    echo "\nINSTALLING ONLY RUNTIME PREREQUISISTES!\n"
    $SUDO_PREFIX apt -y install openjdk-17-jre python3-numpy python3-pandas python3-matplotlib libxerces-c-dev libproj-dev python-dev cmake clang-format uncrustify lldb
fi

$SUDO_PREFIX apt -y install bison flex
