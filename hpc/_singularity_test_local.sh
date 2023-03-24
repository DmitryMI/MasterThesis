#!/bin/bash

source setvars.sh

mkdir -p /tmp/drones_mnt
mkdir -p /tmp/drones_tmp
sudo singularity run --bind /tmp/drones_mnt:/mnt:rw,/tmp/drones_tmp:/tmp:rw $CONTAINERS_DIR/$CONTAINER_NAME 
