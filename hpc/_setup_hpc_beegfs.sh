#!/bin/bash


# Allocating BeeGFS
echo "Testing BeeGFS: $BEEGFS_WORKSPACE"
if [ -d "$BEEGFS_WORKSPACE" ];
then
    echo "BeeGFS already allocated with path $BEEGFS_WORKSPACE"
else
	echo "Allocating BeeGFS..."
	ws_allocate -F beegfs -n drones-workspace -d 30
	if [ $? != 0 ]; 
	then 
	    echo "Failed to allocate BeeGFS!"
	    exit 1
	fi
fi

mkdir -p $BEEGFS_WORKSPACE/work

