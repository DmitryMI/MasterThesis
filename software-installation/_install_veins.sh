VEINS_GIT_LINK="https://github.com/sommer/veins.git"

if test -f "$INSTALLATION_DIR/veins/bin/veins_launchd"; then
	echo "Veins is already installed"
else
	backup_wd=$(pwd)

	cd $INSTALLATION_DIR

	git clone $VEINS_GIT_LINK

	cd veins

	git checkout tags/veins-5.2
	
	export PATH="$PATH:$INSTALLATION_DIR/omnetpp-5.7/bin"

	./configure

	make -j 16
	
	cd $backup_wd
fi

desktop_dir="/home/$(whoami)/Desktop"
desktop_link="$desktop_dir/veins_launchd.desktop"

if test -f "$desktop_link"; then
	echo "Veins desktop link already exists"
else
	touch $desktop_link
	echo "[Desktop Entry]" >> $desktop_link
	echo "Type=Application" >> $desktop_link
	echo "Terminal=true" >> $desktop_link
	echo "Name=Run Veins Launchd" >> $desktop_link
	echo "Icon=$INSTALLATION_DIR/veins/images/veins/node/car_vl.png" >> $desktop_link
	echo "Exec=$INSTALLATION_DIR/veins/bin/veins_launchd -vv" >> $desktop_link
	
	chmod +x $desktop_link
fi

