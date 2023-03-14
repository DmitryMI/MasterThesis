#!/bin/bash

source setvars.sh

mkdir -p $CONTAINERS_DIR

if [[ $1 == "-u" ]]
then
    sudo singularity build --sandbox --update $CONTAINERS_DIR/$CONTAINER_NAME $CONTAINER_NAME.def
else
    sudo singularity build --sandbox $CONTAINERS_DIR/$CONTAINER_NAME $CONTAINER_NAME.def
fi
