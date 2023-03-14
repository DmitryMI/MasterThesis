source setvars.sh

mkdir -p $CONTAINERS_DIR

sudo singularity build $CONTAINERS_DIR/$CONTAINER_NAME.sif $CONTAINER_NAME.def
