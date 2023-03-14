OMPP_LINK="https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.7/omnetpp-5.7-linux-x86_64.tgz"

if [[ $SETVARS_GUARD != 1 ]]
then
    echo "Run setvars.sh or setvars_runtime.sh before running any installation script."
    exit -1
fi


printf "Installing OMNeT++...\n\n"

if test -f "$INSTALLATION_DIR/omnetpp-5.7/bin/omnetpp"; then
	printf "OMNeT++ already installed.\n"
else
	wget --continue --directory-prefix=$DOWNLOADS_DIR $OMPP_LINK

	tar -xzf $DOWNLOADS_DIR/omnetpp-5.7-linux-x86_64.tgz -C $INSTALLATION_DIR

	backup_wd=$(pwd)

	#patch -u $INSTALLATION_DIR/omnetpp-5.7/configure.user -i omnetpp_configure_user.patch

	cd $INSTALLATION_DIR/omnetpp-5.7

	source setenv

    configure_cmd="WITH_OSGEARTH=no"

    if [[ $RUNTIME_ONLY == 1 ]]
    then
        configure_cmd="${configure_cmd} WITH_TKENV=no "
        configure_cmd="${configure_cmd} WITH_QTENV=no "
        configure_cmd="${configure_cmd} WITH_OSG=no "
    fi
    
	./configure	$configure_cmd
	if [[ $? != 0 ]]; then exit -1; fi

	make -j 16
	if [[ $? != 0 ]]; then exit -1; fi
	
	cd $backup_wd	
fi

if test -f ~/.profile; then
    if grep -q "$INSTALLATION_DIR/omnetpp-5.7/bin" ~/.profile; then
        echo "OMNeT++ binaries already in .profile"
    else
        echo "export PATH=\$PATH:$INSTALLATION_DIR/omnetpp-5.7/bin" >> ~/.profile
    fi
fi

if [[ $RUNTIME_ONLY == 0 ]]
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
	    echo "Icon=$INSTALLATION_DIR/omnetpp-5.7/images/logo/logo128m.png" >> $desktop_link
	    echo "Exec=$INSTALLATION_DIR/omnetpp-5.7/bin/omnetpp" >> $desktop_link
	    
	    chmod +x $desktop_link
    fi
fi

if [ "$EUID" == 0 ]
then 
    if grep -q "$INSTALLATION_DIR/omnetpp-5.7/bin" /etc/environment; then
        echo "OMNeT++ binaries already in /etc/environment"
    else
        echo "Exporting omnetpp to /etc/environment"
        echo "PATH=\$PATH:$INSTALLATION_DIR/omnetpp-5.7/bin" >> /etc/environment
    fi
fi
