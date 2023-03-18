#!/bin/bash

source setvars.sh

mkdir -p /tmp/drones_tmp
sudo singularity run --bind /tmp/drones_tmp:/mnt:rw $CONTAINERS_DIR/$CONTAINER_NAME 
