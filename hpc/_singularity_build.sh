#!/bin/bash

source setvars.sh

sin_opts=""

while getopts ":husf-:" optchar; do
	case ${optchar} in	
		
        h) # display Help		 	
		 	echo "-u to update existing container"
		 	echo "-s to enable sandbox"
		 	echo "-f to enable forced rebuild"
		 	exit;;
		 	
		u)
     		echo "Updating enabled"
     		sin_opts="$sin_opts --update"     	
     		;;
     	s)
     	    echo "Sandbox enabled"
     		sin_opts="$sin_opts --sandbox"     	
     		;;	
     	f)
     	    echo "Forced rebuild enabled"
     		sin_opts="$sin_opts --force"     	
     		;;	
	esac
done

mkdir -p $CONTAINERS_DIR

sudo singularity build $sin_opts $CONTAINERS_DIR/$CONTAINER_NAME $CONTAINER_NAME.def

singularity test $CONTAINERS_DIR/$CONTAINER_NAME
