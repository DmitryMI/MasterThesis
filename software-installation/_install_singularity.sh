source "./setvars.sh"

LIBSECCOMP_VERSION="2.5.4"

singularity_version=$(singularity version)
if [[ $? == 0 ]]
then
    echo "Singularity already installed. Version: $singularity_version"
else

    pwd_backup=$(pwd)

    printf "Installing Singularity with dependencies...\n\n"

    source $HOME/.bash_profile

    go_version=$(go version)
    if [[ $? != 0 ]]
    then
        echo "Installing Go..."
        wget 'https://storage.googleapis.com/golang/getgo/installer_linux' --directory-prefix $DOWNLOADS_DIR
        chmod +x $DOWNLOADS_DIR/installer_linux
        $DOWNLOADS_DIR/installer_linux 
        source $HOME/.bash_profile
    else
        echo "Go already installed."
    fi

    echo ""

    echo "GOPATH: $GOPATH"

    if [[ $GOPATH == "" ]]
    then
        echo "GOPATH invalid"
        exit
    fi



    printf "Installing libseccom...\n"

    sudo apt install gperf

    libseccomp_url=https://github.com/seccomp/libseccomp/releases/download/v$LIBSECCOMP_VERSION/libseccomp-$LIBSECCOMP_VERSION.tar.gz
    wget $libseccomp_url --directory-prefix $DOWNLOADS_DIR
    cd $INSTALLATION_DIR
    tar -xzf $DOWNLOADS_DIR/libseccomp-${LIBSECCOMP_VERSION}.tar.gz
    cd libseccomp-${LIBSECCOMP_VERSION}
    ./configure
    make V=1
    sudo make install
    #make check

    if [[ $? != 0 ]]
    then
        echo "libseccomp installation failed"
        exit
    fi



    printf "Installing Singularity...\n"

    mkdir -p ${GOPATH}/src/github.com/sylabs

    cd ${GOPATH}/src/github.com/sylabs

    if [ ! -d ./singularity/.git ]
    then
        echo "Cloning Singularity repository to $(pwd)..."
        git clone --recurse-submodules https://github.com/sylabs/singularity.git 
    else
        echo "Singularity repository already exists in $(pwd). Pulling..."
        cd singularity
        git pull
        cd ..
    fi

    cd singularity
    #git checkout v3.2.1
    ./mconfig
    cd ./builddir 
    make -j8
    sudo make install

    cd $pwd_bacup
fi
