SUMO_LINK="https://sourceforge.net/projects/sumo/files/sumo/version%201.8.0/sumo-src-1.8.0.tar.gz"

ASSUME_DOWNLOADED=1

printf "Installing SUMO...\n\n"

if test -f "$INSTALLATION_DIR/sumo-1.8.0/bin/sumo"; then
	printf "SUMO already installed.\n\n"
else
	if test -f "$DOWNLOADS_DIR/sumo-src-1.8.0.tar.gz"; then
	
		if [[ $ASSUME_DOWNLOADED == 0 ]]; then		
			echo "Cannot resume downloading. Need to restart."
			rm $DOWNLOADS_DIR/sumo-src-1.8.0.tar.gz
			wget --directory-prefix=$DOWNLOADS_DIR $SUMO_LINK
		else
			echo "Assuming SUMO archive is fully downloaded"
		fi
	else
		wget --directory-prefix=$DOWNLOADS_DIR $SUMO_LINK
	fi
			
	if [[ $? != 0 ]];
	then
		exit -1
	fi 

	tar -xzf $DOWNLOADS_DIR/sumo-src-1.8.0.tar.gz -C $INSTALLATION_DIR

	backup_wd=$(pwd)

	cd $INSTALLATION_DIR/sumo-1.8.0
	
	export SUMO_HOME=$(pwd)

	mkdir build/cmake-build
	
	cd build/cmake-build

	cmake ../..

	make -j 16	

	cd $backup_wd	
fi

if grep -q "$INSTALLATION_DIR/sumo-1.8.0/bin" ~/.profile; then
  	echo "SUMO binaries already in .profile"
else
	echo "export PATH=\$PATH:$INSTALLATION_DIR/sumo-1.8.0/bin" >> ~/.profile
fi
