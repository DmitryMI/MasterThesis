OMPP_LINK="https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.7/omnetpp-5.7-linux-x86_64.tgz"

if test -f "$INSTALLATION_DIR/omnetpp-5.7/bin/omnetpp"; then
	echo "OMNeT++ already installed."
else
	wget --continue --directory-prefix=$DOWNLOADS_DIR $OMPP_LINK

	tar -xzf ~/Downloads/omnetpp-5.7-linux-x86_64.tgz -C $INSTALLATION_DIR

	backup_wd=$(pwd)

	patch -u $INSTALLATION_DIR/omnetpp-5.7/configure.user -i omnetpp_configure_user.patch

	cd $INSTALLATION_DIR/omnetpp-5.7

	source setenv

	./configure

	make -j 16

	echo "export PATH=\$PATH:$INSTALLATION_DIR/omnetpp-5.7/bin" >> ~/.profile

	cd $backup_wd	
fi



