cd $MAKE_DIR
make -j 8

if [[ $? != 0 ]]
then
    echo "Building failed!"
    exit
fi

cd $WORKING_DIR
