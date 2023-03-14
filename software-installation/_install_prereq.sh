printf "Installing prerequisites...\n\n"

SUDO_PREFIX=""

if [ "$EUID" -ne 0 ]
then 
    SUDO_PREFIX="sudo"
fi

$SUDO_PREFIX apt -y update
$SUDO_PREFIX apt -y install git-core gitk git-gui tig clang bison flex tcl-dev tk-dev openjdk-17-jre qtbase5-dev libopenscenegraph-dev xvfb libwebkit2gtk-4.0-dev doxygen graphviz python3-numpy python3-pandas python3-matplotlib libxerces-c-dev libproj-dev libgdal-dev libfox-1.6-dev libavformat-dev libavcodec-dev libswscale-dev python-dev cmake xterm clang-format uncrustify valgrind gdb lldb nemiver
