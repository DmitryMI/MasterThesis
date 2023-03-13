source setvars.sh

sudo singularity build $CONTAINERS_DIR/hpc/$CONTAINER_NAME.sif $CONTAINER_NAME.def
