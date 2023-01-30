printf "Installing prerequisites...\n\n"

sudo apt -y update
sudo apt -y install git-core gitk git-gui tig clang bison flex tcl-dev tk-dev openjdk-17-jre qtbase5-dev libopenscenegraph-dev xvfb libwebkit2gtk-4.0-dev doxygen graphviz python3-numpy python3-pandas python3-matplotlib libxerces-c-dev libproj-dev libgdal-dev libfox-1.6-dev libavformat-dev libavcodec-dev libswscale-dev python-dev cmake xterm clang-format uncrustify valgrind gdb lldb nemiver
