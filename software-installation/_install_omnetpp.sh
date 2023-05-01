#!/bin/bash

if [ -z "$OMNETPP_VER" ]
then
    echo "OMNETPP_VER not set!"
    exit 1
fi

# https://github.com/omnetpp/omnetpp/releases/download/omnetpp-6.0.1/omnetpp-6.0.1-linux-x86_64.tgz
OMPP_LINK="https://github.com/omnetpp/omnetpp/releases/download/omnetpp-$OMNETPP_VER/omnetpp-$OMNETPP_VER-linux-x86_64.tgz"

if [ $SETVARS_GUARD != 1 ]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit -1
fi


printf "Installing OMNeT++...\n\n"

if test -f "$INSTALLATION_DIR/omnetpp-$OMNETPP_VER/bin/omnetpp"; then
	printf "OMNeT++ already installed.\n"
else
    sudo pip install posix-ipc
    
	wget --continue --directory-prefix=$DOWNLOADS_DIR $OMPP_LINK

    if [ ! -d $INSTALLATION_DIR/omnetpp-$OMNETPP_VER ]
    then
	    tar -xzf $DOWNLOADS_DIR/omnetpp-$OMNETPP_VER-linux-x86_64.tgz -C $INSTALLATION_DIR
	else
	    echo "$INSTALLATION_DIR/omnetpp-$OMNETPP_VER already exists"
	fi

	backup_wd=$(pwd)

	#patch -u $INSTALLATION_DIR/omnetpp-$OMNETPP_VER/configure.user -i omnetpp_configure_user.patch

	cd $INSTALLATION_DIR/omnetpp-$OMNETPP_VER

	. ./setenv

    configure_cmd="WITH_OSGEARTH=no PREFER_CLANG=no PREFER_LLD=no"

    if [ $RUNTIME_ONLY == 1 ]
    then
        configure_cmd="${configure_cmd} WITH_TKENV=no "
        configure_cmd="${configure_cmd} WITH_QTENV=no "
        configure_cmd="${configure_cmd} WITH_OSG=no "
    fi
    
	./configure	$configure_cmd
	if [ $? != 0 ]; then exit 1; fi

	make -j 16
	if [ $? != 0 ]; then exit 1; fi
	
	cd $backup_wd	
fi

if test -f ~/.profile; then
    if grep -q "$INSTALLATION_DIR/omnetpp-$OMNETPP_VER/bin" ~/.profile; then
        echo "OMNeT++ binaries already in .profile"
    else
        echo "export PATH=\$PATH:$INSTALLATION_DIR/omnetpp-$OMNETPP_VER/bin" >> ~/.profile
    fi
fi

if [ $RUNTIME_ONLY == 0 ]
then   
    desktop_dir="/home/$(whoami)/Desktop"
    desktop_link="$desktop_dir/OMNeT++.desktop"

    if test -f "$desktop_link"; then
	    echo "OMNeT++ desktop link already exists"
    else
	    touch $desktop_link
	    echo "[Desktop Entry]" >> $desktop_link
	    echo "Type=Application" >> $desktop_link
	    echo "Terminal=false" >> $desktop_link
	    echo "Name=OMNeT++" >> $desktop_link
	    echo "Icon=$INSTALLATION_DIR/omnetpp-$OMNETPP_VER/images/logo/logo128m.png" >> $desktop_link
	    echo "Exec=$INSTALLATION_DIR/omnetpp-$OMNETPP_VER/bin/omnetpp" >> $desktop_link
	    
	    chmod +x $desktop_link
    fi
fi

