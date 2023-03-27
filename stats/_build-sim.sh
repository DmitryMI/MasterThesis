cd $MAKE_DIR

source setenv
source ./configure

mkdir -p $MAKE_DIR/veins/bin
mkdir -p $MAKE_DIR/drones_veins_project/bin

make -j 8

if [[ $? != 0 ]]
then
    echo "Building failed!"
    exit
fi

cd $WORKING_DIR
