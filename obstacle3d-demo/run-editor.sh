PROJ_PATH=$(realpath "./Obstacle3dDemo/Obstacle3dDemo.uproject")

cp $PROJ_PATH $PROJ_PATH.backup
./linux-patch-uproject.py

UnrealEditor $PROJ_PATH

rm $PROJ_PATH
mv $PROJ_PATH.backup $PROJ_PATH
