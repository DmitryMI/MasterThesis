#!/bin/bash

source setvars.sh

./singularity_build.sh -u

sudo singularity run $CONTAINERS_DIR/$CONTAINER_NAME
