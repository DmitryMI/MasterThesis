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

echo "Testing Scratch: $SCRATCH_WORKSPACE"
if [ -d "$SCRATCH_WORKSPACE" ];
then
    echo "Scratch already allocated with path $SCRATCH_WORKSPACE"
else
	echo "Allocating BeeGFS..."
	ws_allocate -F scratch -n drones-build -d 30
	if [ $? != 0 ]; 
	then 
	    echo "Failed to allocate Scratch!"
	    exit 1
	fi
fi

